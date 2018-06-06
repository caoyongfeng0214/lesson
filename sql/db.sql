create database if not exists lesson default charset utf8 collate utf8_unicode_ci;

use lesson;

DROP TABLE IF EXISTS `member`;
CREATE TABLE `member` (
  `sn` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '序号',
  `username` varchar(128) COLLATE utf8_unicode_ci NOT NULL COMMENT '用户名',
  `displayName` varchar(512) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '昵称',
  `portrait` varchar(512) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '用户头像',
  `joinTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
  `vipEndTime` datetime DEFAULT NULL COMMENT '权限结束时间',
  `identity` tinyint(4) NOT NULL DEFAULT '1' COMMENT '身份 1.normal 2.教学者',
  `coin` int(11) NOT NULL DEFAULT '200' COMMENT '知识币，初始值为200',
  `firstInFlag` tinyint(4) NOT NULL DEFAULT '1' COMMENT '是否第一次进入 1.是 2.否',
  `codeReadLine` int(11) NOT NULL DEFAULT '0' COMMENT '代码阅读行数',
  `codeWriteLine` int(11) NOT NULL DEFAULT '0' COMMENT '代码书写行数',
  `commands` int(11) NOT NULL DEFAULT '0' COMMENT '学习命令数',
  `presenter` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '推荐人 username',
  PRIMARY KEY (`sn`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

DROP TABLE IF EXISTS `class`;
CREATE TABLE `class` (
  `sn` int(11) NOT NULL AUTO_INCREMENT COMMENT '序号',
  `classId` int(9) DEFAULT NULL COMMENT 'CLASS_ID',
  `teacher` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '教师用户名',
  `lessonUrl` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '课程页面URL',
  `lessonNo` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '课程序号',
  `lessonTitle` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '课程页面标题',
  `lessonCover` varchar(512) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '课程封面地址',
  `goals` varchar(512) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '课程目标',
  `startTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '课程开始时间',
  `finishTime` datetime DEFAULT NULL COMMENT '课程结束时间',
  `summary` text COLLATE utf8_unicode_ci COMMENT '课程总结 JSON 格式',
  `state` tinyint(4) NOT NULL DEFAULT '0' COMMENT '状态 0.start 1.finish',
  `input` varchar(2048) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '输入',
  `output` varchar(2048) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '输出',
  `prerequisite` varchar(2048) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '前置条件',
  PRIMARY KEY (`sn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
  `sn` int(11) NOT NULL AUTO_INCREMENT COMMENT '序号',
  `username` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '用户名',
  `orderTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '下单时间',
  `payTime` datetime DEFAULT NULL COMMENT '支付时间',
  `finishTime` datetime DEFAULT NULL COMMENT '订单完成时间',
  `payWay` tinyint(4) NOT NULL DEFAULT '0' COMMENT '支付方式 0.默认方式',
  `amount` int(11) DEFAULT NULL COMMENT '订单金额',
  `reallyPayAmount` int(11) DEFAULT NULL COMMENT '实际支付金额',
  `lessAmount` int(11) DEFAULT NULL COMMENT '优惠金额',
  `couponID` int(11) DEFAULT NULL COMMENT '优惠券ID',
  `endTime` datetime DEFAULT NULL COMMENT 'vip 有效期',
  `goodsType` tinyint(4) NOT NULL DEFAULT '0' COMMENT '商品类型 0.购买半年 1.购买一年',
  `state` tinyint(4) NOT NULL DEFAULT '0' COMMENT '订单状态 0.已提交 1.已支付 2.已完成  3.已退款 4.失效',
  PRIMARY KEY (`sn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

DROP TABLE IF EXISTS `testrecord`;
CREATE TABLE `testrecord` (
  `sn` int(11) NOT NULL AUTO_INCREMENT COMMENT '序号',
  `username` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '用户名',
  `classSn` int(11) DEFAULT NULL COMMENT '课程序号',
  `classId` varchar(9) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'CLASS_ID',
  `lessonUrl` varchar(512) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '课程页面URL',
  `lessonTitle` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '课程页面标题',
  `lessonCover` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '课程封面地址',
  `goals` varchar(512) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '课程目标',
  `lessonNo` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '课程序号',
  `lessonPerformance` varchar(2048) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '内容总结',
  `beginTime` datetime DEFAULT NULL COMMENT '开始时间',
  `answerSheet` text COLLATE utf8_unicode_ci COMMENT '答题卡 JSON 格式',
  `totalScore` int(11) DEFAULT NULL COMMENT '总得分',
  `rightCount` int(11) DEFAULT NULL COMMENT '答对题数',
  `wrongCount` int(11) DEFAULT NULL COMMENT '答错题数',
  `emptyCount` int(11) DEFAULT NULL COMMENT '未作答题数',
  `finishTime` datetime DEFAULT NULL COMMENT '完成时间',
  `state` tinyint(4) NOT NULL DEFAULT '1' COMMENT '自学状态 1.自学中 2.自学结束',
  `duration` int(11) NOT NULL DEFAULT '0' COMMENT '学习时长（分钟数）',
  `codeReadLine` int(11) NOT NULL DEFAULT '0' COMMENT '代码阅读量',
  `codeWriteLine` int(11) NOT NULL DEFAULT '0' COMMENT '代码书写量',
  `commands` int(11) NOT NULL DEFAULT '0' COMMENT '学习到的命令数量',
  PRIMARY KEY (`sn`),
  UNIQUE KEY `username` (`username`,`classId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

DROP TABLE IF EXISTS `seq`;
CREATE TABLE `seq` (
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '序列名',
  `val` int(11) DEFAULT NULL COMMENT '当前值',
  `step` tinyint(4) NOT NULL DEFAULT '1' COMMENT '步长'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

DROP TABLE IF EXISTS `package`;
CREATE TABLE `package` (
  `id` varchar(128) COLLATE utf8_unicode_ci NOT NULL COMMENT '课程包Id',
  `title` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '标题',
  `cover` varchar(512) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '封面',
  `skills` varchar(512) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '技能点',
  `agesMin` int(11) NOT NULL DEFAULT '0' COMMENT '适合最小年龄 0.suitable4all',
  `agesMax` int(11) DEFAULT NULL COMMENT '适合最大年龄',
  `input` varchar(2048) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '输入，添加该课程包需要什么',
  `output` varchar(2048) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '输出，学完该课程包会得到什么',
  `prerequisite` varchar(2048) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '前置条件',
  `packageUrl` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT 'URL 地址',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

DROP TABLE IF EXISTS `cdkey`;
CREATE TABLE `cdkey` (
  `sn` int(11) NOT NULL AUTO_INCREMENT COMMENT 'cdKey 序号',
  `key` varchar(32) COLLATE utf8_unicode_ci NOT NULL COMMENT '秘钥',
  `createTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `useTime` datetime DEFAULT NULL COMMENT '使用时间',
  `state` tinyint(4) NOT NULL DEFAULT '1' COMMENT '1. normal 2. used 3.forbidden',
  `user` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '使用者 username',
  `userIp` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '使用者 IP',
  PRIMARY KEY (`sn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

DROP TABLE IF EXISTS `package2lesson`;
CREATE TABLE `package2lesson` (
  `packageId` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '课程包Id',
  `lessonUrl` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '对应课程的Url',
  `index` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

DROP TABLE IF EXISTS `subscribe`;
CREATE TABLE `subscribe` (
  `sn` int(11) NOT NULL AUTO_INCREMENT COMMENT '序号',
  `username` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '用户名',
  `createTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `packageId` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '课程包ID',
  `finished` tinyint(4) NOT NULL DEFAULT '1' COMMENT '1. 未完成 2. 已完成',
  `state` tinyint(4) NOT NULL DEFAULT '1' COMMENT '1. normal 2. 未付费订阅（课堂学习）',
  PRIMARY KEY (`sn`),
  UNIQUE KEY `pkg_unique_key` (`username`,`packageId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

# 序列函数
DELIMITER $$
CREATE
    /*[DEFINER = { user | CURRENT_USER }]*/
    FUNCTION `lesson`.`nextval`(seq_name VARCHAR(50))
    RETURNS INTEGER
    /*LANGUAGE SQL
    | [NOT] DETERMINISTIC
    | { CONTAINS SQL | NO SQL | READS SQL DATA | MODIFIES SQL DATA }
    | SQL SECURITY { DEFINER | INVOKER }
    | COMMENT 'string'*/
    BEGIN
	UPDATE seq
          SET val = val + step 
	WHERE NAME = seq_name; 
	RETURN (SELECT val FROM seq WHERE `name` = seq_name); 
    END$$
DELIMITER ;

# 课程序列
INSERT INTO `seq` (`name`, `val`) VALUES ('classSeq', '100000'); 