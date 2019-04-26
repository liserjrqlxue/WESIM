package main

type pipeline struct {
	pipelineName string
	version      string
	steps        []PStep
	files        []PFile
}

type PStep struct {
	Name          string `json:"name"`
	first         int
	stepFlag      int
	computingFlag string
	memory        int
	threads       int
	timeout       int
	moduleIndex   int
	priorStep     []string
	nextStep      []string
	jobSh         []PJob
}

func newPStep(name string) (step PStep) {
	step.Name = name
	step.computingFlag = "cpu"
	step.threads = 1
	step.timeout = 0
	return
}

func (a *PStep) new() {
	a.computingFlag = "cpu"
	a.threads = 1
	a.timeout = 0
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

type PFile struct {
	fileName string
	filePath string
	fileType int
	fileFlag int
}
