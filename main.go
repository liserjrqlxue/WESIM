package main

import (
	"flag"
	"github.com/liserjrqlxue/libIM"
	"github.com/liserjrqlxue/simple-util"
	"log"
	"os"
	"path/filepath"
	"strings"
)

// os
var (
	ex, _  = os.Executable()
	exPath = filepath.Dir(ex)
)

var (
	input = flag.String(
		"input",
		filepath.Join(exPath, "test", "input.list"),
		"input samples info",
	)
	lane = flag.String(
		"lane",
		"",
		"input lane info",
	)
	workDir = flag.String(
		"workdir",
		filepath.Join(exPath, "test", "workdir"),
		"workdir",
	)
	pipeline = flag.String(
		"pipeline",
		filepath.Join(exPath, "pipeline"),
		"pipeline dir",
	)
	stepsCfg = flag.String(
		"stepscfg",
		filepath.Join(exPath, "etc", "allSteps.tsv"),
		"steps config",
	)
)

var keyTitle = []string{
	"main_sample_num",
	"library_num",
	"index_num",
	"pooling_library_num",
	"product_code",
	"FQ_path",
	"platform",
	"lane_code",
	"chip_code",
	"sequencer",
	"hybrid_library_num",
	"gender",
	"proband_number",
	"relationship",
}

var batchDirList = []string{
	"shell",
	"result",
	"javatmp",
}

var sampleDirList = []string{
	"shell",
	"bwa",
	"coverage",
	"annotation",
	"gatk",
	"cnv",
}

var laneDirList = []string{
	"filter",
}

var ProductTrio = map[string]bool{
	"DX0458": false,
	"DX1515": true,
	"HW1101": false,
	"HW1102": true,
}

func main() {
	flag.Parse()
	if *input == "" {
		flag.Usage()
		os.Exit(0)
	}

	simple_util.CheckErr(os.MkdirAll(*workDir, 0755))
	infoList, familyList := parserInput(*input)

	// step0 create workDir
	simple_util.CheckErr(createWorkdir(*workDir, infoList, batchDirList, sampleDirList, laneDirList))
	for probandID, familyInfo := range familyList {
		_, ok := infoList[probandID]
		if !ok {
			log.Fatalf("Error: can nnot find sample info of proband[%s]", probandID)
		}
		createTiroInfo(familyInfo, filepath.Join(*workDir, probandID))
	}
	createSampleInfo(infoList, *workDir)

	stepList, _ := simple_util.File2MapArray(*stepsCfg, "\t", nil)

	var allSteps []libIM.Step
	var stepMap = make(map[string]libIM.Step)
	for _, item := range stepList {
		var step = libIM.NewStep(item)
		if step.CreateJobs(familyList, infoList, ProductTrio, *workDir, *pipeline); step.JobSh != nil {
			stepMap[step.Name] = step
			allSteps = append(allSteps, step)
		}
	}

	for stepName, step := range stepMap {
		for _, prior := range strings.Split(step.Prior, ",") {
			priorStep, ok := stepMap[prior]
			if ok {
				step.PriorStep = append(step.PriorStep, prior)
				priorStep.NextStep = append(priorStep.NextStep, stepName)
			}
		}
	}

	// set first step
	for name, step := range stepMap {
		switch name {
		case "first":
			step.First = 1
		default:
		}
	}
	// write workDir/allSteps.json
	simple_util.CheckErr(simple_util.Json2File(filepath.Join(*workDir, "allSteps.json"), allSteps))
}
