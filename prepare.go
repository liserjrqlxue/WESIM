package main

import (
	"log"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/liserjrqlxue/goUtil/fmtUtil"
	"github.com/liserjrqlxue/goUtil/osUtil"
	"github.com/liserjrqlxue/goUtil/simpleUtil"
	"github.com/liserjrqlxue/goUtil/textUtil"
	"github.com/liserjrqlxue/libIM"
)

func createWorkDir(workDir string, infoMap map[string]libIM.Info, batchDirList, sampleDirList, laneDirList []string) error {
	for _, subDir := range batchDirList {
		simpleUtil.CheckErr(os.MkdirAll(filepath.Join(workDir, subDir), 0755))
	}
	for sampleID, info := range infoMap {
		simpleUtil.CheckErr(os.MkdirAll(filepath.Join(workDir, "result", sampleID), 0755))
		for _, subDir := range sampleDirList {
			simpleUtil.CheckErr(os.MkdirAll(filepath.Join(workDir, sampleID, subDir), 0755))
		}
		for _, laneInfo := range info.LaneInfos {
			for _, subDir := range laneDirList {
				simpleUtil.CheckErr(os.MkdirAll(filepath.Join(workDir, sampleID, subDir, laneInfo.LaneName), 0755))
			}
		}
	}
	return nil
}

func createTrioInfos(familyList map[string]libIM.FamilyInfo, workDir string) {
	for sampleID, familyInfo := range familyList {
		createTrioInfo(familyInfo, filepath.Join(workDir, sampleID))
	}
}

func createTrioInfo(familyInfo libIM.FamilyInfo, workDir string) {
	var f = osUtil.Create(filepath.Join(workDir, "trio.info"))
	defer simpleUtil.DeferClose(f)
	for _, relationShip := range libIM.Trio {
		sampleID, ok := familyInfo.FamilyMap[relationShip]
		if ok {
			fmtUtil.Fprintln(f, sampleID)
		} else {
			log.Fatalf("Error: family Error: can not find relationShip[%s]of proband[%s]\n", relationShip, familyInfo.ProbandID)
		}
	}
}

func createSampleInfo(infoList map[string]libIM.Info, workDir string) {
	var f = osUtil.Create(filepath.Join(workDir, "sample.info"))
	defer simpleUtil.DeferClose(f)
	fmtUtil.Fprintln(f, strings.Join([]string{"main_sample_num", "productType", "StandardQC", "chip_code", "product_code", "gender", "proband_number", "relationship"}, "\t"))
	for _, item := range infoList {
		var array []string
		array = append(array, item.SampleID, item.ProductType, item.StandardQC, item.ChipCode, item.ProductCode, item.Gender, item.ProbandID, item.RelationShip)
		fmtUtil.Fprintln(f, strings.Join(array, "\t"))
	}
}

var sharp = regexp.MustCompile(`^#`)

func parserInput(input string) (infoMap map[string]libIM.Info, familyMap map[string]libIM.FamilyInfo) {
	// parser input list
	sampleList, title := textUtil.File2MapArray(input, "\t", sharp)
	if !*force {
		checkTitle(title)
	}

	infoMap = make(map[string]libIM.Info)
	familyMap = make(map[string]libIM.FamilyInfo)
	// ProbandID -> FamilyInfo
	for _, item := range sampleList {
		var sampleID = item["main_sample_num"]
		var productCode = item["product_code"]
		var probandID = item["proband_number"]
		var relationShip = item["relationship"]

		sampleInfo, ok := infoMap[sampleID]
		if !ok {
			sampleInfo = NewInfo(item)
		}
		var pe = strings.Split(item["FQ_path"], ",")
		if len(pe) != 2 {
			log.Fatalf(
				"can not parse pair end in lane(%s) of sample(%s):[%s]\n",
				item["lane_code"],
				sampleInfo.SampleID,
				item["FQ_path"],
			)
		}
		var lane = libIM.LaneInfo{
			LaneName: item["lane_code"],
			Fq1:      pe[0],
			Fq2:      pe[1],
		}
		sampleInfo.LaneInfos = append(sampleInfo.LaneInfos, lane)

		// FamilyInfo
		if ProductTrio[productCode] {
			familyInfo, ok := familyMap[probandID]
			if ok {
				familyInfo.FamilyMap[relationShip] = sampleID
			} else {
				familyInfo = libIM.FamilyInfo{
					ProbandID: probandID,
					FamilyMap: map[string]string{relationShip: sampleID},
				}
			}
			familyMap[probandID] = familyInfo
		} else {
			sampleInfo.ProbandID = sampleID
		}
		// Should update data of hash if we do not use points as value of hash
		infoMap[sampleID] = sampleInfo
	}
	return
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

func parseStepCfg(cfg string, infoList map[string]libIM.Info, familyList map[string]libIM.FamilyInfo) (map[string]*libIM.Step, []*libIM.Step) {
	var stepList, _ = textUtil.File2MapArray(cfg, "\t", nil)

	var stepMap = make(map[string]*libIM.Step)
	var allSteps []*libIM.Step
	for _, item := range stepList {
		var step = libIM.NewStep(item)
		if step.CreateJobs(familyList, infoList, ProductTrio, *workDir, *pipeline) > 0 {
			stepMap[step.Name] = &step
			allSteps = append(allSteps, &step)
		}
	}

	// link Prior and Next
	libIM.LinkSteps(stepMap)

	var first = false
	for _, step := range allSteps {
		if !first && len(step.PriorStep) == 0 {
			step.First = 1
			first = true
		}
	}

	return stepMap, allSteps
}

func setFirstStep(stepMap map[string]*libIM.Step) {
	for name, step := range stepMap {
		switch name {
		case "first":
			step.First = 1
		default:
		}
	}
}
