package main

import (
	"log"
	"math/rand"
	"os/exec"
	"path"
	"regexp"
	"strings"
	"time"

	"github.com/liserjrqlxue/libIM"
	//"github.com/liserjrqlxue/goUtil/sge"
)

func NewInfo(item map[string]string) libIM.Info {
	return libIM.Info{
		SampleID:     item["main_sample_num"],
		ChipCode:     item["chip_code"],
		Gender:       item["gender"],
		ProductCode:  item["product_code"],
		ProductType:  item["probuctType"],
		ProbandID:    item["proband_number"],
		HPO:          item["HPO"],
		StandardTag:  item["isStandardSample"],
		StandardQC:   item["StandardQC"],
		RelationShip: item["relationship"],
		QChistory:    item["QChistory"],
	}
}

func submitJob(job *libIM.Job, throttle chan bool) {
	log.Printf("submit\t[%s]:[%s]", job.Step.Name, job.Id)
	var hjid = job.WaitPriorChan()
	log.Printf("start\t[%s]:[%s]:[%s]", job.Step.Name, job.Id, job.Sh)
	var jid = job.Id
	if *submit != "" {
		jid = WrapSubmit(*submit, job.Sh, strings.Join(hjid, ","), job.SubmitArgs)
	} else {
		time.Sleep(time.Duration(rand.Int63n(10)) * time.Second)
	}
	job.Done(jid)
	log.Printf("finish\t[%s]:[%s]:[%s]", job.Step.Name, job.Id, jid)
	<-throttle
}

var sgeJobId = regexp.MustCompile(`^Your job (\d+) \("\S+"\) has been submitted\n$`)

func WrapSubmit(submit, script, hjid string, submitArgs []string) (jid string) {
	if hjid != "" {
		submitArgs = append(submitArgs, "-hold_jid", hjid)
	}
	var outDir = path.Dir(script)
	submitArgs = append(submitArgs, "-e", outDir, "-o", outDir)
	var cmds = append(submitArgs, script)
	var c = exec.Command(submit, cmds...)
	log.Printf("%s [%s]", submit, strings.Join(cmds, "]["))
	var submitLogBytes, err = c.CombinedOutput()
	if err != nil {
		log.Fatalf("Error: %v:[%v]", err, submitLogBytes)
	}
	// Your job (\d+) \("script"\) has been submitted
	log.Printf("[%x]", submitLogBytes)
	var submitLogs = sgeJobId.FindStringSubmatch(string(submitLogBytes))
	if len(submitLogs) == 2 {
		jid = submitLogs[1]
	} else {
		log.Fatalf("Error: jid parse error:%v->%v", submitLogBytes, submitLogs)
	}
	return
}
