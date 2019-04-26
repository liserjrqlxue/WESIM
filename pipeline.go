package main

import (
	"path/filepath"
	"strings"
)

type pipeline struct {
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

func (job *PJob) addSampleSh(workdir, sampleID, tag string) {
	job.Sh = filepath.Join(workdir, sampleID, "shell", strings.Join([]string{tag, "sh"}, ","))
}
func (job *PJob) addLaneSh(workdir, sampleID, laneName, tag string) {
	job.Sh = filepath.Join(workdir, sampleID, "shell", strings.Join([]string{tag, laneName, "sh"}, ","))
}

func (step *PStep) addSampleJobs(samples []string, workdir string, mem int) {
	var stepJobs []PJob
	for _, sampleID := range samples {
		var job = newPJob(mem)
		job.addSampleSh(workdir, sampleID, step.Name)
		stepJobs = append(stepJobs, job)
	}
	step.JobSh = &stepJobs
}

func (step *PStep) addLaneJobs(infoList map[string]info, workdir string, mem int) {
	var stepJobs []PJob
	for sampleID, item := range infoList {
		for _, lane := range item.LaneInfo {
			var job = newPJob(mem)
			job.addLaneSh(workdir, sampleID, lane.laneName, step.Name)
			stepJobs = append(stepJobs, job)
		}
	}
	step.JobSh = &stepJobs
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
