create database if not exists lesson default charset utf8 collate utf8_unicode_ci;

use lesson;

DROP TABLE IF EXISTS `member`;
CREATE TABLE `member` (
  `sn` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '序号',
  `username` varchar(128) COLLATE utf8_unicode_ci NOT NULL COMMENT '用户名',
  `joinTime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
  `vipEndTime` datetime DEFAULT NULL COMMENT '权限结束时间',
  PRIMARY KEY (`sn`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

DROP TABLE IF EXISTS `class`;
CREATE TABLE `class` (
  `sn` int(11) NOT NULL AUTO_INCREMENT COMMENT '序号',
  `classId` int(9) DEFAULT NULL COMMENT 'CLASS_ID',
  `teacher` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '教师用户名',
  `lessonUrl` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '课程页面URL',
  `lessonTitle` varchar(256) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '课程页面标题',
  `lessonCover` varchar(512) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '课程封面地址',
  `lessonVedio` varchar(512) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '课程视频地址',
  `goals` varchar(512) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '课程目标',
  `startTime` datetime DEFAULT NULL COMMENT '课程开始时间',
  `finishTime` datetime DEFAULT NULL COMMENT '课程结束时间',
  `summary` text COLLATE utf8_unicode_ci COMMENT '课程总结 JSON 格式',
  `state` tinyint(4) NOT NULL DEFAULT '0' COMMENT '状态 0.start 1.finish',
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
  `beginTime` datetime DEFAULT NULL COMMENT '开始时间',
  `answerSheet` text COLLATE utf8_unicode_ci COMMENT '答题卡 JSON 格式',
  `totalScore` int(11) DEFAULT NULL COMMENT '总得分',
  `rightCount` int(11) DEFAULT NULL COMMENT '答对题数',
  `wrongCount` int(11) DEFAULT NULL COMMENT '答错题数',
  `emptyCount` int(11) DEFAULT NULL COMMENT '未作答题数',
  `finishTime` datetime DEFAULT NULL COMMENT '完成时间',
  PRIMARY KEY (`sn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

DROP TABLE IF EXISTS `seq`;
CREATE TABLE `seq` (
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL COMMENT '序列名',
  `val` int(11) DEFAULT NULL COMMENT '当前值',
  `step` tinyint(4) NOT NULL DEFAULT '1' COMMENT '步长'
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