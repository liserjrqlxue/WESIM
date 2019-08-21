package main

import (
	"github.com/liserjrqlxue/simple-util"
	"path/filepath"
	"strconv"
	"strings"
)

type Pipeline struct {
	pipelineName string
	version      string
	steps        *[]PStep
	files        *[]PFile
}

type PStep struct {
	Name          string   `json:"name"`
	First         int      `json:"first"`
	StepFlag      int      `json:"stepFlag"`
	ComputingFlag string   `json:"computingFlag"`
	Memory        int      `json:"memory"`
	Threads       int      `json:"threads"`
	Timeout       int      `json:"timeout"`
	ModuleIndex   int      `json:"moduleIndex"`
	PriorStep     []string `json:"priorStep"`
	NextStep      []string `json:"nextStep"`
	JobSh         *[]PJob  `json:"jobSh"`
}

func newPStep(name string) (step PStep) {
	step.Name = name
	step.First = 0
	step.ComputingFlag = "cpu"
	step.Threads = 1
	step.Timeout = 0
	step.PriorStep = []string{}
	step.NextStep = []string{}
	step.JobSh = &[]PJob{}
	return
}

type PJob struct {
	ComputingFlag string `json:"computingFlag"`
	Mem           int    `json:"mem"`
	Sh            string `json:"sh"`
}

func newPJob(mem int) (job PJob) {
	job.Mem = mem
	job.ComputingFlag = "cpu"
	return
}

func (job *PJob) addLaneSh(workdir, sampleID, laneName, tag string) {
	job.Sh = filepath.Join(workdir, sampleID, "shell", strings.Join([]string{tag, laneName, "sh"}, "."))
}

func (step *PStep) addLaneJobs(infoList map[string]info, workdir string, mem int) {
	var stepJobs []PJob
	for sampleID, item := range infoList {
		for _, lane := range item.LaneInfo {
			var job = newPJob(mem)
			job.addLaneSh(workdir, sampleID, lane.LaneName, step.Name)
			stepJobs = append(stepJobs, job)
		}
	}
	step.JobSh = &stepJobs
}

func (step *PStep) CreateJobs(stepInfo map[string]string, familyList map[string]FamilyInfo, infoList map[string]info, familyWorkdir, workdir, pipeline string) {
	var stepJobs []PJob

	stepType := stepInfo["type"]
	stepMem, err := strconv.Atoi(stepInfo["mem"])
	simple_util.CheckErr(err)
	stepArgs := strings.Split(stepInfo["args"], ",")
	script := filepath.Join(pipeline, "script", stepInfo["name"]+".sh")

	switch stepType {
	case "family":
		for probandID, familyInfo := range familyList {
			familyProbandDir := filepath.Join(familyWorkdir, probandID)
			var job = newPJob(stepMem)
			job.Sh = filepath.Join(familyProbandDir, "shell", step.Name+".sh")
			stepJobs = append(stepJobs, job)
			var appendArgs []string
			appendArgs = append(appendArgs, filepath.Join(familyProbandDir), pipeline)
			for _, arg := range stepArgs {
				switch arg {
				case "list":
					for _, relationShip := range []string{"proband", "father", "mother"} {
						appendArgs = append(appendArgs, familyInfo.FamilyMap[relationShip])
					}
				case "single":
					appendArgs = append(appendArgs, workdir)
				case "HPO":
					appendArgs = append(appendArgs, infoList[probandID].HPO)
				}
			}
			createShell(job.Sh, script, appendArgs...)
		}
	case "batch":
		var job = newPJob(stepMem)
		job.Sh = filepath.Join(workdir, "shell", step.Name+".sh")
		stepJobs = append(stepJobs, job)
		var appendArgs []string
		appendArgs = append(appendArgs, workdir, pipeline)
		for _, arg := range stepArgs {
			switch arg {
			case "laneInput":
				appendArgs = append(appendArgs, *lane)
			}
		}
		createShell(job.Sh, script, appendArgs...)
	case "sample":
		for sampleID, item := range infoList {
			var job = newPJob(stepMem)
			job.Sh = filepath.Join(workdir, sampleID, "shell", step.Name+".sh")
			stepJobs = append(stepJobs, job)
			var appendArgs []string
			appendArgs = append(appendArgs, workdir, pipeline, sampleID)
			for _, arg := range stepArgs {
				switch arg {
				case "laneName":
					for _, lane := range item.LaneInfo {
						appendArgs = append(appendArgs, lane.LaneName)
					}
				case "gender":
					appendArgs = append(appendArgs, item.Gender)
				case "HPO":
					appendArgs = append(appendArgs, item.HPO)
				case "StandardTag":
					appendArgs = append(appendArgs, item.StandardTag)
				}
			}
			createShell(job.Sh, script, appendArgs...)
		}
	case "lane":
		for sampleID, item := range infoList {
			for _, lane := range item.LaneInfo {
				var job = newPJob(stepMem)
				job.Sh = filepath.Join(workdir, sampleID, "shell", step.Name+"."+lane.LaneName+".sh")
				stepJobs = append(stepJobs, job)
				var appendArgs []string
				appendArgs = append(appendArgs, workdir, pipeline, sampleID)
				for _, arg := range stepArgs {
					switch arg {
					case "laneName":
						appendArgs = append(appendArgs, lane.LaneName)
					case "fq1":
						appendArgs = append(appendArgs, lane.Fq1)
					case "fq2":
						appendArgs = append(appendArgs, lane.Fq2)
					}
				}
				createShell(job.Sh, script, appendArgs...)
			}
		}
	}
	step.JobSh = &stepJobs
}

func (step *PStep) createLaneShell(infoList map[string]info, item map[string]string, workDir, pipelineDir string) {
	for sampleID, info := range infoList {
		args := strings.Split(item["args"], ",")
		for _, lane := range info.LaneInfo {
			var appendArgs []string
			appendArgs = append(appendArgs, workDir, pipelineDir, sampleID)
			for _, arg := range args {
				switch arg {
				case "laneName":
					appendArgs = append(appendArgs, lane.LaneName)
				case "fq1":
					appendArgs = append(appendArgs, lane.Fq1)
				case "fq2":
					appendArgs = append(appendArgs, lane.Fq2)
				}
			}

		}
	}
}

func flowSteps(steps ...*PStep) {
	for i, step := range steps {
		if i < len(steps)-1 {
			step.NextStep = append(step.NextStep, steps[i+1].Name)
		}
		if i > 0 {
			step.PriorStep = append(step.PriorStep, steps[i-1].Name)
		}
	}
}

func flowDown2Ups(downStep *PStep, upSteps ...*PStep) {
	for _, upStep := range upSteps {
		upStep.NextStep = append(upStep.NextStep, downStep.Name)
		downStep.PriorStep = append(downStep.PriorStep, upStep.Name)
	}
}

func flowUp2Downs(upStep *PStep, downSteps ...*PStep) {
	for _, downStep := range downSteps {
		upStep.NextStep = append(upStep.NextStep, downStep.Name)
		downStep.PriorStep = append(downStep.PriorStep, upStep.Name)
	}
}

type PFile struct {
	fileName string
	filePath string
	fileType int
	fileFlag int
}
