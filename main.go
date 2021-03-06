package main

import (
	"flag"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"

	"github.com/liserjrqlxue/goUtil/jsonUtil"
	"github.com/liserjrqlxue/goUtil/osUtil"
	"github.com/liserjrqlxue/goUtil/simpleUtil"
	"github.com/liserjrqlxue/libIM"
	"github.com/liserjrqlxue/version"
)

// os
var (
	ex, _   = os.Executable()
	exPath  = filepath.Dir(ex)
	etcPath = filepath.Join(exPath, "etc")
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
		"steps",
		filepath.Join(etcPath, "allSteps.tsv"),
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
	header = flag.String(
		"header",
		filepath.Join(etcPath, "script.header.sh"),
		"change script header",
	)
	footer = flag.String(
		"footer",
		filepath.Join(etcPath, "script.footer.sh"),
		"change script footer",
	)
	run = flag.Bool(
		"run",
		false,
		"if run or submit",
	)
	pe = flag.Bool(
		"pe",
		true,
		"if must pair end",
	)
)

var keyTitle = []string{
	"main_sample_num",
	"index_num",
	"product_code",
	"FQ_path",
	"platform",
	"lane_code",
	"chip_code",
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
	version.LogVersion()
	flag.Parse()
	if *input == "" || *workDir == "" {
		flag.Usage()
		os.Exit(0)
	}
	if *lane != "" {
		libIM.LaneInput = *lane
	}
	if *header != "" && osUtil.FileExists(*header) {
		libIM.ScriptHeader = string(simpleUtil.HandleError(ioutil.ReadFile(*header)).([]byte))
	}
	if *footer != "" && osUtil.FileExists(*footer) {
		libIM.ScriptFooter = string(simpleUtil.HandleError(ioutil.ReadFile(*footer)).([]byte))
	}
	var infoList, familyList = parserInput(*input, *pe)

	simpleUtil.CheckErr(createWorkDir(*workDir, infoList, batchDirList, sampleDirList, laneDirList))

	// write workDir/probandID/trio.info
	// createTrioInfos(familyList, *workDir)

	// write workDir/sample.info
	createSampleInfo(infoList, *workDir)

	var _, allSteps = parseStepCfg(*stepsCfg, infoList, familyList)

	// write workDir/allSteps.json
	simpleUtil.CheckErr(jsonUtil.Json2File(filepath.Join(*workDir, "allSteps.json"), allSteps))

	if !*run {
		return
	}

	// copy -input to -workdir/input.list
	simpleUtil.CheckErr(osUtil.CopyFile(filepath.Join(*workDir, "input.list"), *input))

	var throttle = make(chan bool, libIM.Threshold)
	var jobChan = make(chan bool, 1024)

	for _, step := range allSteps {
		for _, job := range step.JobSh {
			jobChan <- true
			go submitJob(job, throttle, jobChan)
		}
	}

	for i := 0; i < 1024; i++ {
		jobChan <- true
	}

	for i := 0; i < libIM.Threshold; i++ {
		throttle <- true
	}
	log.Printf("All Done!")
}
