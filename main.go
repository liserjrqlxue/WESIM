package main

import (
	"flag"
	"log"
	"os"
	"path/filepath"

	"github.com/liserjrqlxue/goUtil/jsonUtil"
	"github.com/liserjrqlxue/goUtil/simpleUtil"
	"github.com/liserjrqlxue/libIM"
)

// os
var (
	ex, _  = os.Executable()
	exPath = filepath.Dir(ex)
)

var (
	input = flag.String(
		"input",
		"",
		"input samples info",
	)
	lane = flag.String(
		"lane",
		"",
		"input lane info",
	)
	workDir = flag.String(
		"workdir",
		"",
		"workDir",
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
	force = flag.Bool(
		"force",
		false,
		"if not check input title",
	)
	submit = flag.String(
		"submit",
		"",
		"submit wrap script if submit jobs",
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
	if *input == "" || *workDir == "" {
		flag.Usage()
		os.Exit(0)
	}
	if *lane != "" {
		libIM.LaneInput = *lane
	}

	var infoList, familyList = parserInput(*input)

	simpleUtil.CheckErr(createWorkDir(*workDir, infoList, batchDirList, sampleDirList, laneDirList))

	// write workDir/probandID/trio.info
	createTrioInfos(familyList, *workDir)

	// write workDir/sample.info
	createSampleInfo(infoList, *workDir)

	var _, allSteps = parseStepCfg(*stepsCfg, infoList, familyList)
	allSteps[0].First = 1

	// write workDir/allSteps.json
	simpleUtil.CheckErr(jsonUtil.Json2File(filepath.Join(*workDir, "allSteps.json"), allSteps))

	var throttle = make(chan bool, libIM.Threshold)

	for _, step := range allSteps {
		for _, job := range step.JobSh {
			throttle <- true
			go submitJob(job, throttle)
		}
	}

	for i := 0; i < libIM.Threshold; i++ {
		throttle <- true
	}
	log.Printf("All Done!")
}
