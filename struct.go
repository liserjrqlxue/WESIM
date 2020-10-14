package main

import (
	"log"
	"os/exec"
	"path"
	"regexp"
	"strings"

	"github.com/liserjrqlxue/libIM"
	simple_util "github.com/liserjrqlxue/simple-util"
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
	if simple_util.FileExists(job.Sh + ".complete") {
		log.Printf("skip\t[%s]:[%s]", job.Step.Name, job.Id)
		job.Done("")
		return
	}
	var hjid = job.WaitPriorChan()
	throttle <- true
	log.Printf("start\t[%s]:[%s]:[%s]", job.Step.Name, job.Id, job.Sh)
	var jid = job.Id
	if *submit != "" {
		jid = WrapSubmit(*submit, job.Sh, strings.Join(hjid, ","), job.SubmitArgs)
		job.Done(jid)
		log.Printf("finish\t[%s]:[%s]:[%s]", job.Step.Name, job.Id, jid)
	} else {
		var err = simple_util.RunCmd("bash", job.Sh)
		if err == nil {
			job.Done(jid)
			log.Printf("finish\t[%s]:[%s]:[%s]", job.Step.Name, job.Id, jid)
		} else {
			log.Printf("error\t[%s]:[%s]:[%s]\t%v", job.Step.Name, job.Id, jid, err)
		}
	}
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
		log.Fatalf("Error: %v:[%v]", err, string(submitLogBytes))
	}
	// Your job (\d+) \("script"\) has been submitted
	log.Print(string(submitLogBytes))
	var submitLogs = sgeJobId.FindStringSubmatch(string(submitLogBytes))
	if len(submitLogs) == 2 {
		jid = submitLogs[1]
	} else {
		log.Fatalf("Error: jid parse error:%v->%v", submitLogBytes, submitLogs)
	}
	return
}
