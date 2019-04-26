package main

import (
	"path/filepath"
	"strings"
)

type pipeline struct {
	pipelineName string
	version      string
	steps        []PStep
	files        []PFile
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
	JobSh         []PJob   `json:"jobSh"`
}

func newPStep(name string) (step PStep) {
	step.Name = name
	step.First = 0
	step.ComputingFlag = "cpu"
	step.Threads = 1
	step.Timeout = 0
	return
}

type PJob struct {
	computingFlag string
	mem           int
	sh            string
}

func newPJob(mem int) (job PJob) {
	job.computingFlag = "cpu"
	return
}

func (job *PJob) addSampleSh(workdir, sampleID, tag string) {
	job.sh = filepath.Join(workdir, sampleID, "shell", strings.Join([]string{tag, "sh"}, ","))
}
func (job *PJob) addLaneSh(workdir, sampleID, laneName, tag string) {
	job.sh = filepath.Join(workdir, sampleID, "shell", strings.Join([]string{tag, laneName, "sh"}, ","))
}

func (step *PStep) addSampleJobs(samples []string, workdir string, mem int) {
	var stepJobs []PJob
	for _, sampleID := range samples {
		var job = newPJob(mem)
		job.addSampleSh(workdir, sampleID, step.Name)
		stepJobs = append(stepJobs, job)
	}
	step.JobSh = stepJobs
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
	step.JobSh = stepJobs
}

type PFile struct {
	fileName string
	filePath string
	fileType int
	fileFlag int
}
