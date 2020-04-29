package main

import (
	"flag"
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

	// write workDir/allSteps.json
	simpleUtil.CheckErr(jsonUtil.Json2File(filepath.Join(*workDir, "allSteps.json"), allSteps))
}
