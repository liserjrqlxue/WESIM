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
	family = flag.String(
		"family",
		"",
		"input family info",
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

type laneInfo struct {
	LaneName string `json:"lane_code"`
	Fq1      string `json:"fastq1"`
	Fq2      string `json:"fastq2"`
}

type info struct {
	SampleID         string
	PoolingID        string
	Gender           string
	ProbandID        string
	ProbandPoolingID string
	LaneInfo         []laneInfo
	FamilyInfo       map[string][]string
}

var poolingDirList = []string{
	"graph_singleBaseDepth",
	"ExomeDepth",
	"CNVkit",
	"SMA",
	"shell",
}

var sampleDirList = []string{
	"shell",
	"bwa",
	"coverage",
	"annotation",
	filepath.Join("gatk", "UG", "snv"),
	filepath.Join("gatk", "HC", "short_indel"),
}

var laneDirList = []string{
	"filter",
}

func main() {
	flag.Parse()
	if *input == "" {
		flag.Usage()
		os.Exit(0)
	}

	var singleWorkdir = filepath.Join(*workdir, "single")
	var familyWorkdir = filepath.Join(*workdir, "family")

	// parser input list
	sampleList, title := simple_util.File2MapArray(*input, "\t", nil)
	checkTitle(title)
	var poolingList = make(map[string]int)
	var infoList = make(map[string]info)
	for _, item := range sampleList {
		var poolingID = item["pooling_library_num"]
		var sampleID = item["main_sample_num"]
		var probandID = item["proband_number"]
		var gender = item["gender"]
		var laneCode = item["lane_code"]
		var fqPath = item["FQ_path"]
		var pe = strings.Split(fqPath, ",")
		if len(pe) != 2 {
			log.Fatalf("can not parse pair end in lane(%s) of sample(%s):[%s]\n", laneCode, sampleID, fqPath)
		}
		var lane = laneInfo{
			LaneName: laneCode,
			Fq1:      pe[0],
			Fq2:      pe[1],
		}
		sampleInfo, ok := infoList[sampleID]
		if !ok {
			sampleInfo.SampleID = sampleID
			sampleInfo.Gender = gender
			sampleInfo.PoolingID = poolingID
			sampleInfo.ProbandID = probandID
		}
		sampleInfo.LaneInfo = append(sampleInfo.LaneInfo, lane)
		infoList[sampleID] = sampleInfo
		poolingList[poolingID]++
	}
	var samples []string
	for k := range infoList {
		samples = append(samples, k)
	}

	stepList, _ := simple_util.File2MapArray(*stepsCfg, "\t", nil)

	// step0 create workdir
	err := os.MkdirAll(singleWorkdir, 0755)
	simple_util.CheckErr(err)
	createWorkdir(singleWorkdir, poolingList, infoList, poolingDirList, sampleDirList, laneDirList)

	var allSteps []*PStep
	var stepMap = make(map[string]*PStep)
	for _, item := range stepList {
		var step = newPStep(item["name"])
		step.createJobs(infoList, poolingList, item, singleWorkdir, *pipeline)
		step.PriorStep = append(step.PriorStep, strings.Split(item["prior"], ",")...)
		step.NextStep = append(step.NextStep, strings.Split(item["next"], ",")...)

		stepMap[item["name"]] = &step
		allSteps = append(allSteps, &step)
	}

	for name, step := range stepMap {
		switch name {
		case "filter":
			step.First = 1
		default:
		}
	}
	for pooling := range poolingList {
		simple_util.Json2File(filepath.Join(singleWorkdir, pooling, "allSteps.json"), allSteps)
	}

	// parser family list
	if *family == "" {
		return
	}
	familyList, title := simple_util.File2MapArray(*family, "\t", nil)
	var familyInfo = make(map[string]map[string][]string)
	var poolingMap = make(map[string]string)
	for _, item := range familyList {
		sampleID := item["main_sample_num"]
		probandID := item["proband_number"]
		relationship := item["relationship"]
		pooling := item["pooling_library_num"]
		poolingMap[sampleID] = pooling
		info, ok := familyInfo[probandID]
		if ok {
			info[relationship] = append(info[relationship], sampleID)
		} else {
			var familyMember = make(map[string][]string)
			familyMember[relationship] = append(familyMember[relationship], sampleID)
			familyInfo[probandID] = familyMember
		}
	}
	for sampleID, item := range infoList {
		member, ok := familyInfo[item.ProbandID]
		if ok {
			item.FamilyInfo = member
			item.ProbandPoolingID, ok = poolingMap[item.ProbandID]
			if !ok {
				log.Printf("can not find poolingID of proband[%s]\n", item.ProbandID)
			} else {
				infoList[sampleID] = item
				simple_util.CheckErr(os.MkdirAll(filepath.Join(familyWorkdir, item.PoolingID), 0755))
				source := filepath.Join(singleWorkdir, item.PoolingID, item.SampleID)
				dest := filepath.Join(familyWorkdir, item.ProbandPoolingID, item.SampleID)
				_, err := os.Stat(dest)
				if err == nil {
					readLink, err := os.Readlink(dest)
					if err != nil {
						log.Printf("%v\n", err)
					}
					if readLink != source {
						log.Printf("dest is not link to source:[%s]->[%s]vs[%s]\n", dest, readLink, source)
						err = os.Symlink(source, dest)
						if err != nil {
							log.Printf("%v\n", err)
						}
					} else {
						log.Printf("dest is link to source:[%s]->[%s]", dest, readLink)
					}
				} else if os.IsNotExist(err) {
					err = os.Symlink(source, dest)
					if err != nil {
						log.Printf("%v\n", err)
					}
				} else {
					log.Printf("dest stat err:%v [%s]\n", err, dest)
				}
			}
		} else {
			log.Printf("Proband[%s] no in family.list[%s]\n", item.ProbandID, *family)
		}
	}
	//jsonByte,err:=json.MarshalIndent(infoList,"","\t")
	//fmt.Printf("%s\n",jsonByte)
}

func createShell(fileName, script string, args ...string) {
	file, err := os.Create(fileName)
	simple_util.CheckErr(err)
	defer simple_util.DeferClose(file)

	_, err = fmt.Fprintf(file, "#!/bin/bash\nsh \\\n\t%s \\\n\t%s\n", script, strings.Join(args, " \\\n\t"))
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
