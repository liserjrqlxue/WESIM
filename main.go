package main

import (
	"flag"
	"fmt"
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
	//pSep   = string(os.PathSeparator)
	//dbPath       = exPath + pSep + "db" + pSep
	//templatePath = exPath + pSep + "template" + pSep
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
	workdir = flag.String(
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

var singleDirList = []string{
	//"graph_singleBaseDepth",
	//"ExomeDepth",
	//"CNVkit",
	//"SMA",
	"shell",
	"result",
}

var sampleDirList = []string{
	"shell",
	"bwa",
	"coverage",
	"annotation",
	"gatk",
}

var laneDirList = []string{
	"filter",
}

var ProductTrio = map[string]bool{
	"DX0458": false,
	"DX1515": true,
	"HW101":  false,
	"HW102":  true,
}

func main() {
	flag.Parse()
	if *input == "" {
		flag.Usage()
		os.Exit(0)
	}

	var singleWorkdir = *workdir //filepath.Join(*workdir, "single")
	var familyWorkdir = *workdir //filepath.Join(*workdir, "family")
	simple_util.CheckErr(os.MkdirAll(singleWorkdir, 0755))
	simple_util.CheckErr(os.MkdirAll(familyWorkdir, 0755))

	infoList, familyList := parserInput(*input, *workdir)

	// step0 create workdir
	simple_util.CheckErr(createWorkdir(singleWorkdir, infoList, singleDirList, sampleDirList, laneDirList))
	for probandID, familyInfo := range familyList {
		_, ok := infoList[probandID]
		if !ok {
			log.Fatalf("Error: can nnot find sample info of proband[%s]", probandID)
		}
		createTiroInfo(familyInfo, filepath.Join(familyWorkdir, probandID))
	}
	createSampleInfo(infoList, *workdir)

	stepList, _ := simple_util.File2MapArray(*stepsCfg, "\t", nil)

	var allSteps []*PStep
	var stepMap = make(map[string]*PStep)
	for _, item := range stepList {
		var step = newPStep(item["name"])
		step.CreateJobs(item, familyList, infoList, familyWorkdir, singleWorkdir, *pipeline)
		if item["prior"] != "" {
			step.PriorStep = append(step.PriorStep, strings.Split(item["prior"], ",")...)
		}
		if item["next"] != "" {
			step.NextStep = append(step.NextStep, strings.Split(item["next"], ",")...)
		}

		stepMap[item["name"]] = step
		allSteps = append(allSteps, step)
	}

	for name, step := range stepMap {
		switch name {
		case "first":
			step.First = 1
		default:
		}
	}
	simple_util.CheckErr(simple_util.Json2File(filepath.Join(*workdir, "allSteps.json"), allSteps))
}

func createShell(fileName, script string, args ...string) {
	file, err := os.Create(fileName)
	simple_util.CheckErr(err)
	defer simple_util.DeferClose(file)

	_, err = fmt.Fprintf(file, "#!/bin/bash\nsh %s %s\n", script, strings.Join(args, " "))
	simple_util.CheckErr(err)
}

func checkTitle(title []string) {
	var titleMap = make(map[string]bool)
	for _, key := range keyTitle {
		titleMap[key] = false
	}
	for _, key := range title {
		titleMap[key] = true
	}
	for k, v := range titleMap {
		if !v {
			log.Fatalf("not contain title[%s]\n", k)
		}
	}
}
