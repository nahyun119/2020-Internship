-- MySQL dump 10.13  Distrib 8.0.21, for macos10.15 (x86_64)
--
-- Host: dev-nahyun.cnr0irr3vons.ap-northeast-2.rds.amazonaws.com    Database: DoItPower
-- ------------------------------------------------------
-- Server version	8.0.17

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ '';

--
-- Dumping routines for database 'DoItPower'
--
/*!50003 DROP FUNCTION IF EXISTS `calculate_prize` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` FUNCTION `calculate_prize`(
	in_user_uid int,
    in_contest_uid int,
    in_contest_status int
) RETURNS int(11)
BEGIN
	declare user_point int;
	declare total_point int;
    declare fitness_rate int;
    declare fee_rate int;
    
    /* 전체 참여금 계산 */
    set total_point = (select sum(_member.point) 
						from tbl_contest_member as _member
                        where _member.contest_uid = in_contest_uid
							and _member.is_deleted = 0);

    /* 수수료 제외 총 참여금(수수료 30%) */                        
    set total_point = total_point * 0.7;  
	/* 본인 참여금 계산 (참여하고 진행중인 경우, 참여했으나 인원 미달로 진행x인 경우) 나머지는 50000 point*/
    if(in_contest_status = 6 or in_contest_status = 4) then
		set user_point = (select point from _member where user_uid = in_user_uid);
    else
		set user_point = 50000;
    end if;
    
    /* 대회 상금 지수, 휘트니스 혜택 가져오기 */
    select fitness_reward_rate, fee_rate into fitness_rate, fee_rate
		from tbl_contest where uid = in_contest_uid;
    
    /* 상금 수령자(상위 30%) 금액 가져오기 */
    
    
RETURN 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `func_calculate_remaining_point` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` FUNCTION `func_calculate_remaining_point`(
	in_user_uid int
) RETURNS int(11)
BEGIN
	declare add_point int;
    declare save_point int;
    declare use_point int;
    declare not_refund_point int;
    declare refund_point int;
    declare remaining_point int;
    
    
	/* 충전한 포인트 총 합 */
	select ifnull(sum(value),0)
		into add_point 
		from tbl_point 
        where user_uid = in_user_uid
        and type = 1
        and is_deleted = 0;
    
   /* 적립한 포인트 총 합 */
	select ifnull(sum(value), 0)
		into save_point 
		from tbl_point 
        where user_uid = in_user_uid
        and type = 2
        and is_deleted = 0;
    
   /* 사용한 포인트 총 합 */
	select ifnull(sum(value), 0) 
		into use_point 
		from tbl_point 
        where user_uid = in_user_uid
        and type = 3
        and is_deleted = 0; 
    
   /* 환급 예정인 포인트 총 합 */
	select ifnull(sum(value) , 0)
		into not_refund_point 
		from tbl_point 
        where user_uid = in_user_uid
        and type = 11
        and is_deleted = 0; 
   
   /* 환급한 포인트 총 합 */
	select ifnull(sum(value), 0)
		into refund_point 
		from tbl_point 
        where user_uid = in_user_uid
        and type = 12
        and is_deleted = 0;
        
    /* null인 경우 0으로 지정해줘야 후에 잔여포인트랑 참가 포인트 비교할 때 제대로 이루어진다.  */    
    
    set remaining_point = add_point + save_point - 
		(use_point + not_refund_point + refund_point);   
        
RETURN if(remaining_point is null, 0, remaining_point);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `func_select_contest_status_single` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` FUNCTION `func_select_contest_status_single`(
    in_user_uid int, in_contest_uid int
) RETURNS int(11)
BEGIN
/*
	0 :		 참여 모집 중 & 참여 o & 인원 미달o
    1 :		 참여 모집 중 & 참여 o & 인원 미달x
    2 : 	 참여 모집 중 & 참여 x & 참여 가능(인원 초과x)
    3 : 	 참여 모집 중 & 참여 x & 참여 불가(인원 초과o)
    4 : 	 참여 모집 후 & 참여 o & 진행 불가(인원 미달o)
	5 : 	 참여 모집 후 & 참여 o & 진행 가능(인원 미달x)
    6 : 	 참여 모집 후 & 참여 x, 그 밖에 다른 경우
*/
    declare status int;
    declare is_participated int;
    
    set is_participated = (select count(*) 
							from tbl_contest_member
							where contest_uid = in_contest_uid
                            and user_uid = in_user_uid);
    
    set status = (
        select case
                   /* 참여 모집 중인 경우*/
                   when _contest.start_date > now() and is_participated = 1 and 
						_contest.limit_min > count(_member.uid)
                       then 0
                   when _contest.start_date > now() and is_participated = 1 and 
						_contest.limit_min <= count(_member.uid)
                       then 1    
                   when _contest.start_date > now() and is_participated != 1 and
                        _contest.limit_max > count(_member.uid)
                       then 2
                   when _contest.start_date > now() and is_participated != 1 and
                        _contest.limit_max <= count(_member.uid)
                       then 3
                   /* 참여 마감한 후인 경우 */
                   when _contest.start_date <= now() and is_participated = 1 and
                        _contest.limit_min > count(_member.uid)
                       then 4
                   when _contest.start_date <= now() and is_participated = 1 and
                        _contest.limit_min <= count(_member.uid)
                       then 5
                   when _contest.start_date <= now() and is_participated != 1
                       then 6
                   else 6
                   end as status
        from tbl_contest as _contest
                 /* contest에 참여하는 멤버 테이블과 join, contest를 기준으로 member을 join 한다. */
                 left join tbl_contest_member as _member on
                _member.contest_uid = _contest.uid
                and _member.is_deleted = 0
        where _contest.uid = in_contest_uid
          and _contest.is_deleted = 0);

    RETURN status;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP FUNCTION IF EXISTS `func_select_contest_status_team` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` FUNCTION `func_select_contest_status_team`(
    in_user_uid int, in_contest_uid int
) RETURNS int(11)
BEGIN
/*
	0 :		 참여 모집 중 & 참여 o & 인원 미달o
    1 :		 참여 모집 중 & 참여 o & 인원 미달x
    2 : 	 참여 모집 중 & 참여 x & 참여 가능(인원 초과x)
    3 : 	 참여 모집 중 & 참여 x & 참여 불가(인원 초과o)
    4 : 	 참여 모집 후 & 참여 o & 진행 불가(인원 미달o)
	5 : 	 참여 모집 후 & 참여 o & 진행 가능(인원 미달x)
    6 : 	 참여 모집 후 & 참여 x, 그 밖에 다른 경우
*/
    declare status int;
    
    declare is_participated int;
    
    set is_participated = (select count(*) 
							from tbl_contest_member
							where contest_uid = in_contest_uid
                            and user_uid = in_user_uid
                            and is_deleted = 0);
    set status = (
        select case
                   /* 참여 모집 중인 경우*/
                   when _contest.start_date > now() and is_participated = 1 and
						_contest.limit_min > count(_team.uid)
                       then 0
                   when _contest.start_date > now() and is_participated = 1 and
						_contest.limit_min <= count(_team.uid)
                       then 1   
                   when _contest.start_date > now() and is_participated != 1 and
                        _contest.limit_max > count(_team.uid)
                       then 2
                   when _contest.start_date > now() and is_participated != 1 and
                        _contest.limit_max <= count(_team.uid)
                       then 3
                   /* 참여 마감한 후인 경우 */
                   when _contest.start_date <= now() and is_participated = 1 and
                        _contest.limit_min > count(_team.uid)
                       then 4
                   when _contest.start_date <= now() and is_participated = 1 and
                        _contest.limit_min <= count(_team.uid)
                       then 5
                   when _contest.start_date <= now() and is_participated != 1
                       then 6
                   else 6
                   end as status
        from tbl_contest as _contest
                 /* contest에 참여하는 team 테이블과 join, contest를 기준으로 team을 join 한다. */
                 left join tbl_contest_team _team on
				_team.contest_uid = in_contest_uid
                and _team.is_deleted = 0
        where _contest.uid = in_contest_uid
          and _contest.is_deleted = 0);

    RETURN status;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `proc_create_contest_member` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `proc_create_contest_member`(
	IN in_contest_uid int,
    IN in_user_uid int,
    IN in_type int,
    IN in_team_name varchar(45),
    IN in_team_pwd varchar(45),
    IN in_point int
)
BEGIN
	/* 신규 생성인 경우 in type = 1 */
    /* 개인전인 경우 in type = 1으로 하면 된다. 새로 팀을 생성하는 것과 동일하므로 */
    /* 기존 팀에 참가하는 경우 in type = 2 */
	if(in_type = 1) then
		call proc_create_contest_team(
				in_contest_uid, 
				in_user_uid, 
				in_team_name, 
                in_team_pwd,
                in_point);
	else 
		call proc_update_contest_team(
				in_contest_uid, 
                in_user_uid,
                in_team_name,
                in_team_pwd,
				in_point);
	END IF;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `proc_create_contest_team` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `proc_create_contest_team`(
	IN in_contest_uid int,
    IN in_user_uid int,
    IN in_team_name varchar(45),
    IN in_team_pwd varchar(45),
    IN in_point int
)
BEGIN

	/*
	 0 : 참가 불가 -> 잔여 포인트 < 대회 참가 포인트인 경우
     1 : 참가 불가 -> 팀명 또는 비밀번호가 일치하지 않는 경우
     2 : 참가 불가 -> 팀을 모두 모집한 경우 
     3 : 참가 불가 -> 팀 이름이 중복된 경우 
     4 : 참가 가능 
    */	

	/* 팀명 중복 체크 */
    /* 개인전인 경우 팀명이 null이 되므로 null을 제외한 부분에 대해서 중복을 체크한다. */ 
	declare duplication int;
	declare last_team_uid int;
    
    set duplication = (select count(*) 
						from tbl_contest_team
                        where contest_uid = in_contest_uid 
						and team_name = in_team_name
						and not team_name is null
                        and is_deleted = 0);
                        
    /* 중복이 아닌 경우 */                    
    if(duplication = 0) then
		insert into tbl_contest_team 
			set contest_uid = in_contest_uid,
				leader_uid = in_user_uid,
                team_name = in_team_name,
                pwd = in_team_pwd,
                leader_point = in_point,
                /* 개인전인 경우 team_name이 null인데 그러면 모집 완료 상태가 되고, 아니라면 
                팀전이라는 의미이므로 모집 중인 상태가 된다. */
                status = if(in_team_name = NULL, 2, 1);
         
         
         /* 생성한 팀의 uid를 가져온다. */   
        set last_team_uid = (select max(uid) 
								from tbl_contest_team 
                                where contest_uid = in_contest_uid 
                                and leader_uid = in_user_uid);     
                                
         /* 생성한 팀의 멤버로 등록한다. */       
        insert into tbl_contest_member 
			set contest_uid = in_contest_uid,
				contest_team_uid = last_team_uid,
                user_uid = in_user_uid,
                point = in_point;
        
        /* 참가 이후 포인트 사용 정보를 등록한다. */
        insert into tbl_point 
			set user_uid = in_user_uid,
				value = in_point,
                type = 3,
                contest = (select title 
							from tbl_contest
							where uid = in_contest_uid);
                
		/* 생성된 멤버 정보를 가져온다. */	
        select * from tbl_contest_member 
				where contest_uid = in_contest_uid
				and user_uid = in_user_uid;
                
    /* 팀 이름이 중복된 경우 */            
    ELSE select 3 as result;            
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `proc_select_contest_check_available` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `proc_select_contest_check_available`(
	IN in_contest_uid int,
    IN in_user_uid int,
    IN in_type int,
    IN in_team_name varchar(45),
    IN in_team_pwd varchar(45),
    IN in_point int
)
check_available : BEGIN
	
    declare _team_uid int;
    declare _team_status int;
    declare _team_count int;
    declare remaining_point int;
    
	/*
	 0 : 참가 불가 -> 잔여 포인트 < 대회 참가 포인트인 경우
     1 : 참가 불가 -> 팀명 또는 비밀번호가 일치하지 않는 경우
     2 : 참가 불가 -> 팀을 모두 모집한 경우 
     3 : 참가 불가 -> 팀 이름이 중복된 경우 
     4 : 참가 가능 
    */

	/* 사용자 남은 포인트 계산 */
	set remaining_point = (select func_calculate_remaining_point(in_user_uid));
    
    /* 잔여 포인트 < 참가 포인트인 경우 참가 불가*/
    if(remaining_point < in_point) then
		select remaining_point as result;
        leave check_available;
    end if;
    
    /* 개인전인 경우 또는 팀을 새로 생성하는 경우 더이상 확인할 필요 없으므로 procedure 종료  */   
    /* 팀을 새로 생성하는 경우 생성하는 procedure에서 팀명 중복을 알려주기 때문에 여기서 확인할 필요x */
    if(in_type = 1) then
		select 4 as result;
		leave check_available;
    end if;
    
    /* 대회에 참가한 팀명과 비밀번호를 이용해서 팀 정보를 가져온다. */
	select uid, team_count, status into _team_uid, _team_count, _team_status
		from tbl_contest_team as _team
		where contest_uid = in_contest_uid
        and team_name = in_team_name
        and pwd = in_team_pwd;
        
    /* 팀 이름과 비밀번호와 일치하는 팀 정보가 없는 경우 */    
    IF(_team_uid IS NULL) then
		select 1 as result;
        leave check_available;
    END IF;
    
    /* 팀원 모집이 완료된 경우  */
    IF(_team_status = 2) then 
		select 2 as result;
        leave check_available;
    END IF;     
          
	select 4 as result;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `proc_select_contest_count` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `proc_select_contest_count`(
	IN in_contest_uid int,
    IN in_user_uid int
)
BEGIN
	declare join_count int;
    set join_count = (select count(*) 
						from tbl_contest_member 
                        where contest_uid = in_contest_uid
                        and is_deleted = 0);
	select contest_member.*
		, dense_rank() over(order by team_certify_count DESC) / join_count * 100 as ranking
		, _user.uid as user_uid
        , _user.nickname
        , if(_member.contest_team_uid = (select contest_team_uid 
											from tbl_contest_member
											where user_uid = in_user_uid
                                            and contest_uid = in_contest_uid
											and is_deleted = 0), 1, 0) as is_participated
        from (
			select *
				, sum(_certify_count) / team_count as team_certify_count
                /* 상위 30% 참여금을 구해야할 때 필요  */
                , sum(point) as team_point
				from (
					select _team.*
						, if(_byUser.user_uid = _member.user_uid, _byUser._count, 0) as _certify_count
                        , _member.point as point
                        from tbl_contest_team as _team
							/* member 별 참여 포인트를 알려줘야 하기때문에 member table을 가져온다. */
									left join tbl_contest_member as _member 
										on _member.contest_uid = in_contest_uid
										and _member.is_deleted = 0
										
							/* group by user_uid해서 user마다 그룹화하고 그룹 내 데이터 개수를 가져온다. */
									left join (select contest_uid, user_uid, is_deleted, count(uid) as _count 
												from tbl_certify 
												group by user_uid) as _byUser
										on _byUser.contest_uid = in_contest_uid
										and _byUser.is_deleted = 0
										
							where _team.contest_uid = in_contest_uid
								/* 인증 테이블에서 사용자마다 가져온 데이터와 contest에 참여하는 member 데이터가 같은 경우  */
								and _byUser.user_uid = _member.user_uid
								/* 참여자들의 팀 uid랑 실제 team 테이블의 uid가 같은 경우  */
								and _member.contest_team_uid = _team.uid
                                and _team.is_deleted = 0
						   ) as certify_count
						   group by uid
						) as contest_member
                        
		/* 팀원 정보 혹은 개인 정보를 보여줘야하기 때문에 user table을 join */ 
			left join (select user_uid, contest_team_uid 
						from tbl_contest_member
                        where is_deleted = 0) as _member
				on contest_member.uid = _member.contest_team_uid
                
			left join (select uid, nickname 
						from tbl_user
                        where is_deleted = 0) as _user
				on _user.uid = _member.user_uid;
                

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `proc_select_contest_down` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `proc_select_contest_down`(
		IN in_contest_uid int,
        IN in_user_uid int
)
BEGIN
	
    declare join_count int;
    set join_count = (select count(*) 
						from tbl_contest_member 
                        where contest_uid = in_contest_uid
                        and is_deleted = 0);
                        
    /* 계산된 팀 별 감량, 증가, 인증 지수를 이용해서 ranking 계산*/
	/* contest type이 down인 경우 많을수록 좋은 것이기 때문에 오름차순 정렬을 해서 랭킹 계산 */
    
	select team_df.* 
		, dense_rank() over(order by team_difference DESC) / join_count * 100 as ranking
		, _user.uid as user_uid
		, _user.nickname
		, if(_member.contest_team_uid = (select contest_team_uid 
												from tbl_contest_member
												where user_uid = in_user_uid
												and contest_uid = in_contest_uid
												and is_deleted = 0), 1, 0) as is_participated
	from 
	( 
		select *
				/* 계산된 개인 별 감량, 증가, 인증 지수를 이용해서 팀 별 지수 계산 */
					, sum(member_difference) / team_count as team_difference
					, sum(point) as team_point
					from ( 
					/* 각 팀의 멤버들이 인증 결과를 통해 개인 별 감량, 증가, 인증 횟수 계산  */
						select _team.*
							, if(_member.contest_team_uid = _team.uid, _max.value - _min.value, 0)  as member_difference
							, _member.point as point
							from tbl_contest_team as _team
								/* 팀원들 정보를 알아야 하기 때문에 member table join*/
								left join tbl_contest_member as _member
									on _member.contest_team_uid = _team.uid
									and _member.is_deleted = 0
								/* 해당 대회에서 user uid 마다 제일 처음 인증한 데이터 가져오기*/
								left join (select * from tbl_certify
														where uid in (
														select MAX(uid) 
															from tbl_certify 
															group by user_uid
														) order by user_uid DESC ) as _max
										on _max.contest_uid = in_contest_uid
										and _max.is_deleted = 0
										
								/* 해당 대회에서 user uid 마다 제일 최근에 인증한 데이터 가져오기*/
								left join (select * from tbl_certify as _min
														where uid in (
														select MIN(uid) 
															from tbl_certify 
															group by user_uid
														) order by user_uid DESC) as _min
										on _min.contest_uid = in_contest_uid
										and _min.is_deleted = 0
							where _team.contest_uid = in_contest_uid
								and _max.user_uid = _min.user_uid
								and _member.user_uid = _max.user_uid
								and _team.is_deleted = 0
						   ) as certify_calculation
					group by uid) as team_df
				left join (select user_uid, contest_team_uid 
							from tbl_contest_member
							where is_deleted = 0) as _member
					on _member.contest_team_uid = team_df.uid
				left join (select uid, nickname 
							from tbl_user
							where is_deleted = 0) as _user
					on _user.uid = _member.user_uid;
			 
                    
						
        
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `proc_select_contest_leader_point` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `proc_select_contest_leader_point`(
	IN in_contest_uid int,
    IN in_team_name varchar(45),
    IN in_team_pwd varchar(45)
)
BEGIN
	select leader_point
		from tbl_contest_team
		where contest_uid = in_contest_uid
        and team_name = in_team_name
        and pwd = in_team_pwd;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `proc_select_contest_not_start` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `proc_select_contest_not_start`(
	IN in_contest_uid int,
    IN in_user_uid int
)
BEGIN
	select _team.uid, _team.created_time, 
						   _team.updated_time, _team.is_deleted, 
                           _team.contest_uid, _team.team_name,
                           _team.team_count, _team.leader_point,
                           _team.status
		, if(_member.user_uid = in_user_uid, _team.pwd, null) as pwd
        , if(_member.contest_team_uid = (select contest_team_uid 
											from tbl_contest_member
											where user_uid = in_user_uid
                                            and contest_uid = in_contest_uid
											and is_deleted = 0), 1, 0) as is_participated
        , _user.uid as user_uid
        , _user.nickname
        , _member.point as point
        , 1 as ranking 
		from tbl_contest_team as _team
        /* 대회 참여 멤버와 멤버의 이름을 알기 위해서 member, user table join */
        left join tbl_contest_member as _member
				on _team.uid = _member.contest_team_uid
                and _member.is_deleted = 0
		left join (select uid, nickname 
						from tbl_user
                        where is_deleted = 0) as _user
				on _user.uid = _member.user_uid
        where _team.contest_uid = in_contest_uid
			and _team.is_deleted = 0
		order by _team.uid;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `proc_select_contest_participation` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `proc_select_contest_participation`(
	IN in_contest_uid int,
    IN in_user_uid int
)
get_participation_list : BEGIN
	declare _victory_type varchar(45);
    declare _start_date date;
    
    select victory_type, start_date into _victory_type, _start_date
		from tbl_contest 
        where uid = in_contest_uid;
        
    /* 현재 날짜가 시작 날짜보다 뒤인 경우는 진행 전인 경우이므로
	   이 때 참여 현황은 팀정보 (개인전 정보), 닉네임을 보여주고 랭킹은 1로 동일하게 나타낸다.
	*/
    if(_start_date > now()) then
		call proc_select_contest_not_start(in_contest_uid, in_user_uid);
        
    /* 진행 중인 경우 인증 데이터를 이용해 실제 랭킹을 계산할 수 있도록 한다.  */    
	else 	
		if(_victory_type = 'up') then
			call proc_select_contest_up(in_contest_uid, in_user_uid);
			
		elseif(_victory_type = 'down') then
			call proc_select_contest_down(in_contest_uid, in_user_uid);
			
		else 
			call proc_select_contest_count(in_contest_uid, in_user_uid);
			
		end if;    
    end if;    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `proc_select_contest_participation_detail` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `proc_select_contest_participation_detail`(
	IN in_contest_uid int,
    IN in_user_uid int
)
BEGIN
	select _certify.*
		, _max.value - _min.value as current_grade
        , _user.nickname
		from tbl_certify as _certify
			/* 해당 대회에서 제일 처음 인증한 데이터 가져오기*/
			left join (select * from tbl_certify
							where uid in (
							select distinct MAX(uid) 
								from tbl_certify 
								where user_uid = in_user_uid)) as _max
            on _max.contest_uid = in_contest_uid
            and _max.is_deleted = 0
            /* 해당 대회에서 제일 최근에 인증한 데이터 가져오기*/
            left join (select * from tbl_certify
							where uid in (
							select distinct MIN(uid) 
								from tbl_certify 
								where user_uid = in_user_uid)) as _min
            on _min.contest_uid = in_contest_uid 
            and _min.is_deleted = 0
            /* 사용자 정보 가져오기 */
            left join tbl_user as _user
			on _user.uid = in_user_uid
            and _user.is_deleted = 0
            
        where _certify.contest_uid = in_contest_uid
			and _certify.user_uid = in_user_uid
            and _certify.is_deleted = 0;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `proc_select_contest_up` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `proc_select_contest_up`(
	IN in_contest_uid int,
    IN in_user_uid int
)
BEGIN
	declare join_count int;
    set join_count = (select count(*) 
						from tbl_contest_member 
                        where contest_uid = in_contest_uid
                        and is_deleted = 0);
                        
    /* 계산된 팀 별 감량, 증가, 인증 지수를 이용해서 ranking 계산*/
	/* contest type이 up인 경우 적을수록 좋은 것이기 때문에 오름차순 정렬을 해서 랭킹 계산 */
    
	select team_df.* 
		, dense_rank() over(order by team_difference) / join_count * 100 as ranking
		, _user.uid as user_uid
		, _user.nickname
		, if(_member.contest_team_uid = (select contest_team_uid 
												from tbl_contest_member
												where user_uid = in_user_uid
												and contest_uid = in_contest_uid
												and is_deleted = 0), 1, 0) as is_participated
	from 
	( 
		select *
				/* 계산된 개인 별 감량, 증가, 인증 지수를 이용해서 팀 별 지수 계산 */
					, sum(member_difference) / team_count as team_difference
					, sum(point) as team_point
					from ( 
					/* 각 팀의 멤버들이 인증 결과를 통해 개인 별 감량, 증가, 인증 횟수 계산  */
						select _team.*
							, if(_member.contest_team_uid = _team.uid, _max.value - _min.value, 0)  as member_difference
							, _member.point as point
							from tbl_contest_team as _team
								/* 팀원들 정보를 알아야 하기 때문에 member table join*/
								left join tbl_contest_member as _member
									on _member.contest_team_uid = _team.uid
									and _member.is_deleted = 0
								/* 해당 대회에서 user uid 마다 제일 처음 인증한 데이터 가져오기*/
								left join (select * from tbl_certify
														where uid in (
														select MAX(uid) 
															from tbl_certify 
															group by user_uid
														) order by user_uid DESC ) as _max
										on _max.contest_uid = in_contest_uid
										and _max.is_deleted = 0
										
								/* 해당 대회에서 user uid 마다 제일 최근에 인증한 데이터 가져오기*/
								left join (select * from tbl_certify as _min
														where uid in (
														select MIN(uid) 
															from tbl_certify 
															group by user_uid
														) order by user_uid DESC) as _min
										on _min.contest_uid = in_contest_uid
										and _min.is_deleted = 0
							where _team.contest_uid = in_contest_uid
								and _max.user_uid = _min.user_uid
								and _member.user_uid = _max.user_uid
								and _team.is_deleted = 0
						   ) as certify_calculation
					group by uid) as team_df
				left join (select user_uid, contest_team_uid 
							from tbl_contest_member
							where is_deleted = 0) as _member
					on _member.contest_team_uid = team_df.uid
				left join (select uid, nickname 
							from tbl_user
							where is_deleted = 0) as _user
					on _user.uid = _member.user_uid;
                
                    
        
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `proc_update_contest_member` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `proc_update_contest_member`(
	IN in_contest_uid int,
    IN in_user_uid int
)
BEGIN
	declare _title text;
    declare _start_date date;
    
    set sql_safe_updates = 0;
    
    select title, start_date
					into _title, _start_date
					from tbl_contest 
					where uid = in_contest_uid
					and is_deleted = 0;

	update tbl_contest_member as _member
		/* 팀 정보를 수정해야하기 때문에 join*/
        /* 팀원을 한명 줄인다.*/
		left join tbl_contest_team as _team
        on _member.contest_team_uid = _team.uid
        and _team.is_deleted = 0
        
        /* 대회 참가 시 사용한 포인트 정보를 삭제해야하기 때문에 join*/
        left join tbl_point as _point
        on _point.user_uid = _member.user_uid
        and _point.content = _title
        and _point.is_deleted = 0
        
        set _member.is_deleted = 1,
            _point.is_deleted = 1,
            _team.team_count = _team.team_count - 1,
            /* 팀원을 한명 줄였을 때 0이 되면 팀원이 없는 것이므로 삭제, is_deleted를 1로 하고 
			   0이 아닌 경우 삭제하면 안되므로 is_deleted = 0*/
			_team.is_deleted = if(_team.team_count - 1 = 0, 1, 0),
            /* 팀원이 모집 완료 상태이면서 참가 모집 중이라면 
				팀원이 한명 나간 경우 모집 완료에서 모집 중으로 변경이 되야한다. 
                한명만 있는데 나간 경우는 팀이 삭제되므로 상태를 변경할 필요가 없다. */
            _team.status = if(_team.status = 2 and _start_date > now(), 1, _team.status)
        where _member.contest_uid = in_contest_uid
			and _member.user_uid = in_user_uid
			and _member.is_deleted = 0;
            
            
	set sql_safe_updates = 1;
    
    select * from tbl_contest_member 
		where contest_uid = in_contest_uid
        and user_uid = in_user_uid;
   
   
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `proc_update_contest_team` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `proc_update_contest_team`(
	IN in_contest_uid int,
    IN in_user_uid int,
    IN in_team_name varchar(45),
    IN in_team_pwd varchar(45),
    IN in_point int
)
proc_body : BEGIN
	/*
	 0 : 참가 불가 -> 잔여 포인트 < 대회 참가 포인트인 경우
     1 : 참가 불가 -> 팀명 또는 비밀번호가 일치하지 않는 경우
     2 : 참가 불가 -> 팀을 모두 모집한 경우 
     3 : 참가 불가 -> 팀 이름이 중복된 경우 
     4 : 참가 가능 
    */
    
	declare _team_uid int;
    declare _team_status int;
    declare _team_count int;
	
	set sql_safe_updates = 0;
	/* 대회에 참가한 팀명과 비밀번호를 이용해서 팀 정보를 가져온다. */
	select uid, team_count, status into _team_uid, _team_count, _team_status
		from tbl_contest_team as _team
		where contest_uid = in_contest_uid
        and team_name = in_team_name
        and pwd = in_team_pwd
        and is_deleted = 0;
    
    /* 팀원을 모집 중인 경우*/
	IF(_team_status = 1) THEN
		/* 팀 멤버 추가 */
		insert into tbl_contest_member
			set contest_uid = in_contest_uid,
				contest_team_uid = _team_uid,
                user_uid = in_user_uid,
                point = in_point;
                
		update tbl_contest_team 
			/* 멤버 추가하고나서 팀 최대 인원인지 아닌지 확인하고 최대 인원인 경우 모집 완료 상태, 아니면 모집 중 */        
			set status = if(_team_count + 1 = 2, 2, 1),
				team_count = _team_count + 1;
        
        /* 대회 참가하고나서 포인트 사용 정보 등록 */
        insert into tbl_point 
			set user_uid = in_user_uid,
				value = in_point,
                type = 3,
                content = (select title 
							from tbl_contest
							where uid = in_contest_uid);
                            
		/* 추가한 멤버 정보 가져오기 */
        select * from tbl_contest_member 
				 where contest_uid = in_contest_uid
                 and user_uid = in_user_uid;
                 
    /* 팀이 모집 완료 상태인 경우 */             
	ELSE select 2 as result;				
    END IF;	
    set sql_safe_updates = 1;
        
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `v1_proc_create_account` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `v1_proc_create_account`(IN in_timezone varchar(45), IN in_email varchar(45),
                                                         IN in_pwd varchar(45), IN in_type varchar(10),
                                                         IN in_social_id tinytext, IN in_social_access_token tinytext,
                                                         IN in_birthday date, IN in_nickname varchar(45),
                                                         IN in_gender varchar(10), IN in_fitness_name varchar(45),
                                                         IN in_fitness_trainer varchar(45),
                                                         IN in_fitness_trainer_phone varchar(45),
                                                         IN in_fitness_address tinytext,
                                                         IN in_fitness_postcode varchar(45), IN in_push_token tinytext,
                                                         IN in_os varchar(45), IN in_version_app varchar(45))
BEGIN

    insert into tbl_user
    set email = in_email
      , pwd = sha1(in_pwd)
      , type = in_type
      , social_id   = in_social_id
      , social_access_token      = in_social_access_token

      , birthday   = in_birthday
      , nickname   = in_nickname
      , gender   = in_gender

      , fitness_name   = in_fitness_name
      , fitness_trainer   = in_fitness_trainer
      , fitness_trainer_phone   = in_fitness_trainer_phone
      , fitness_address   = in_fitness_address
      , fitness_postcode   = in_fitness_postcode

      , push_token   = in_push_token
      , os   = in_os
      , version_app   = in_version_app
    ;

    call v1_proc_select_user_info(in_timezone, last_insert_id());

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `v1_proc_select_contest_detail` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `v1_proc_select_contest_detail`(IN in_timezone varchar(45), IN in_user_uid int, IN in_contest_uid int)
BEGIN

    select _contest.*
		 , case
                when _contest.contest_type = 'single'
                    then func_select_contest_status_single(in_user_uid, in_contest_uid)
                when _contest.contest_type = 'team'
                    then func_select_contest_status_team(in_user_uid, in_contest_uid)
           END AS status
         , if(_team.leader_uid=in_user_uid, 1, 0) as is_leader
         , convert_tz(_contest.created_time, 'utc', in_timezone) as created_time
         , convert_tz(_contest.updated_time, 'utc', in_timezone) as updated_time
         , ifnull(sum(_member.point), 0) as total_point
         , ifnull(count(_member.uid), 0) as join_count
         , ifnull(count(_team.uid), 0) as team_count
   from tbl_contest as _contest
             left outer join tbl_contest_team as _team
                             on _team.contest_uid = _contest.uid
                                 and _team.is_deleted = 0
             left outer join tbl_contest_member as _member
                             on _member.contest_uid = _contest.uid
                                 and _member.is_deleted = 0
    where _contest.is_deleted = 0
      and _contest.uid = in_contest_uid
    group by _contest.uid
    limit 1
    ;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `v1_proc_select_contest_my_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `v1_proc_select_contest_my_list`(IN in_timezone varchar(45), IN in_user_uid int)
BEGIN

    select _contest.*
         , convert_tz(_contest.created_time, 'utc', in_timezone) as created_time
         , convert_tz(_contest.updated_time, 'utc', in_timezone) as updated_time
         , ifnull(sum(_member.point), 0) as total_point
         , ifnull(count(_member.uid), 0) as join_count
         , ifnull(count(_team.uid), 0) as team_count
#          , (select v1_func_select_contest_total_point(_contest.uid)) as total_point
    from tbl_contest as _contest
             left outer join tbl_contest_team as _team
                             on _team.contest_uid = _contest.uid
                                 and _team.is_deleted = 0
             left outer join tbl_contest_member as _member
                             on _member.contest_uid = _contest.uid
                                 and _member.is_deleted = 0
    where _contest.is_deleted = 0
      and _contest.start_date > now()
      and _member.user_uid = in_user_uid
    group by _contest.uid
    order by _contest.start_date asc

    limit 100
    ;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `v1_proc_select_contest_search_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `v1_proc_select_contest_search_list`(IN in_timezone varchar(45), IN in_user_uid int)
BEGIN

    select _contest.*
         , convert_tz(_contest.created_time, 'utc', in_timezone) as created_time
         , convert_tz(_contest.updated_time, 'utc', in_timezone) as updated_time
         , ifnull(sum(_member.point), 0) as total_point
         , ifnull(count(_member.uid), 0) as join_count
         , ifnull(count(_team.uid), 0) as team_count
#          , (select v1_func_select_contest_total_point(_contest.uid)) as total_point
    from tbl_contest as _contest
             left outer join tbl_contest_team as _team
                             on _team.contest_uid = _contest.uid
                                 and _team.is_deleted = 0
             left outer join tbl_contest_member as _member
                             on _member.contest_uid = _contest.uid
                                 and _member.user_uid != in_user_uid
                                 and _member.is_deleted = 0
    where _contest.is_deleted = 0
      and _contest.start_date > now()
    group by _contest.uid
    order by _contest.start_date asc

    limit 100
    ;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `v1_proc_select_email_check` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `v1_proc_select_email_check`(IN in_timezone varchar(45), IN in_email varchar(45))
BEGIN

    select _user.uid
         , _user.email
         , _user.nickname
         , _user.type
         , convert_tz(_user.created_time, 'utc', in_timezone) as created_time
         , convert_tz(_user.updated_time, 'utc', in_timezone) as updated_time
    from tbl_user as _user
    where _user.email = in_email
      and _user.is_deleted = 0
    ;
    
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `v1_proc_select_event_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `v1_proc_select_event_list`(IN in_timezone varchar(45), IN in_user_uid int)
BEGIN

    declare v_postcode varchar(10);

    select _user.fitness_postcode into v_postcode
    from tbl_user as _user
    where _user.uid = in_user_uid
      and _user.is_deleted = 0
    limit 1;

    select _event.*
         , _image.filename
         , convert_tz(_event.created_time, 'utc', in_timezone) as created_time
         , convert_tz(_event.updated_time, 'utc', in_timezone) as updated_time
    from tbl_event as _event
       , ( select __image.*
           from tbl_image as __image
           where __image.is_deleted = 0
             and __image.seq = 1 ) as _image
    where _event.uid = _image.target_uid
      and _event.is_popup_show = 0
      and _event.is_deleted = 0
      and (isnull(_event.postcode) or _event.postcode = v_postcode)
      and _image.code = 3
    limit 30
    ;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `v1_proc_select_event_popup` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `v1_proc_select_event_popup`(IN in_timezone varchar(45), IN in_user_uid int)
BEGIN

    declare v_postcode varchar(10);

    select _user.fitness_postcode into v_postcode
    from tbl_user as _user
    where _user.uid = in_user_uid
      and _user.is_deleted = 0
    limit 1;

    select _event.*
         , _image.filename
         , convert_tz(_event.created_time, 'utc', in_timezone) as created_time
         , convert_tz(_event.updated_time, 'utc', in_timezone) as updated_time
    from tbl_event as _event
       , ( select __image.*
           from tbl_image as __image
           where __image.is_deleted = 0
             and __image.seq = 1 ) as _image
    where _event.uid = _image.target_uid
      and _event.is_popup_show = 1
      and _event.is_deleted = 0
      and _image.code = 4
      and (isnull(_event.postcode) or _event.postcode = v_postcode)
#       and _event.postcode = v_postcode
    order by _event.uid desc
    limit 1
    ;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `v1_proc_select_login_email` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `v1_proc_select_login_email`(IN in_timezone varchar(45), IN in_email varchar(45),
                                                             IN in_pwd varchar(45))
BEGIN

    select _user.*
         , convert_tz(_user.created_time, 'utc', in_timezone) as created_time
         , convert_tz(_user.updated_time, 'utc', in_timezone) as updated_time
         , null as pwd
         , null as access_token
         , null as bank_code_id
         , null as bank_account_number
         , null as social_id
         , null as social_access_token
    from tbl_user as _user
    where _user.is_deleted = 0
      and _user.email = in_email
      and _user.pwd = sha1(in_pwd)
    order by _user.uid desc
    limit 1
    ;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `v1_proc_select_login_social` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `v1_proc_select_login_social`(IN in_timezone varchar(45),
                                                              IN in_social_id tinytext,
                                                              IN in_type varchar(10) )
BEGIN

    select _user.*
         , convert_tz(_user.created_time, 'utc', in_timezone) as created_time
         , convert_tz(_user.updated_time, 'utc', in_timezone) as updated_time
         , null as pwd
         , null as access_token
         , null as bank_code_id
         , null as bank_account_number
         , null as social_id
         , null as social_access_token
    from tbl_user as _user
    where _user.is_deleted = 0
      and _user.social_id = in_social_id
      and _user.type = in_type
    order by _user.uid desc
    limit 1
    ;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `v1_proc_select_social_id_check` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `v1_proc_select_social_id_check`(IN in_timezone varchar(45), IN in_social_id tinytext, IN in_type varchar(45))
BEGIN

    select _user.uid
         , _user.email
         , _user.nickname
         , _user.type
         , convert_tz(_user.created_time, 'utc', in_timezone) as created_time
         , convert_tz(_user.updated_time, 'utc', in_timezone) as updated_time
    from tbl_user as _user
    where _user.social_id = in_social_id
      and _user.type = in_type
      and _user.is_deleted = 0
    ;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `v1_proc_select_user_access_token_check` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `v1_proc_select_user_access_token_check`(IN in_timezone varchar(45), IN in_user_uid int, IN in_access_token tinytext)
BEGIN

    select _user.uid
         , _user.email
         , _user.nickname
         , _user.type
         , convert_tz(_user.created_time, 'utc', in_timezone) as created_time
         , convert_tz(_user.updated_time, 'utc', in_timezone) as updated_time
    from tbl_user as _user
    where _user.uid = in_user_uid
      and _user.access_token = in_access_token
      and _user.is_deleted = 0
    ;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `v1_proc_select_user_info` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `v1_proc_select_user_info`(IN in_timezone varchar(45), IN in_user_uid int)
BEGIN

    select _user.*
         , convert_tz(_user.created_time, 'utc', in_timezone) as created_time
         , convert_tz(_user.updated_time, 'utc', in_timezone) as updated_time
         , null as pwd
         , null as access_token
         , null as bank_code_id
         , null as bank_account_number
         , null as social_id
         , null as social_access_token

    from tbl_user as _user
    where _user.uid = in_user_uid
      and _user.is_deleted = 0
    ;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `v1_proc_select_user_nickname_check` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `v1_proc_select_user_nickname_check`(IN in_timezone varchar(45), IN in_nickname varchar(45))
BEGIN

    select _user.uid
         , _user.email
         , _user.nickname
         , _user.type
         , convert_tz(_user.created_time, 'utc', in_timezone) as created_time
         , convert_tz(_user.updated_time, 'utc', in_timezone) as updated_time
    from tbl_user as _user
    where _user.nickname = in_nickname
      and _user.is_deleted = 0
    ;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `v1_proc_select_user_pwd_check` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `v1_proc_select_user_pwd_check`(IN in_timezone varchar(45), IN in_user_uid int,
                                                                IN in_pwd varchar(45))
BEGIN

    select _user.uid
         , _user.email
         , _user.nickname
         , _user.type
         , _user.is_deleted
         , convert_tz(_user.created_time, 'utc', in_timezone) as created_time
         , convert_tz(_user.updated_time, 'utc', in_timezone) as updated_time
    from tbl_user as _user
    where _user.uid = in_user_uid
      and _user.pwd = sha1(in_pwd)
    ;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `v1_proc_update_user_access_token` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `v1_proc_update_user_access_token`(IN in_timezone varchar(45), IN in_user_uid int,
                                                                   IN in_access_token tinytext)
begin

    set sql_safe_updates = 0;

    update tbl_user
    set updated_time	= now()
      , last_connection = now()
      , access_token    = in_access_token
    where uid = in_user_uid;

    set sql_safe_updates = 1;
    
    call v1_proc_select_user_info(in_timezone, in_user_uid);


end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `v1_proc_update_user_default_info` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `v1_proc_update_user_default_info`(IN in_timezone varchar(45), IN in_user_uid int,
                                                                   IN in_access_token tinytext,
                                                                   IN in_social_access_token tinytext,
                                                                   IN in_push_token tinytext, IN in_os varchar(10),
                                                                   IN in_version_app varchar(45))
begin

    set sql_safe_updates = 0;

    update tbl_user
    set updated_time	= now()
      , access_token    = in_access_token
      , social_access_token = in_social_access_token
      , push_token    = in_push_token
      , os              = in_os
      , version_app     = in_version_app
    where uid = in_user_uid;

    set sql_safe_updates = 1;

    call v1_proc_select_user_info(in_timezone, in_user_uid);


end ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `v1_proc_update_user_fitness` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `v1_proc_update_user_fitness`(IN in_timezone varchar(45),
                                                              IN in_user_uid int,
                                                              IN in_fitness_name varchar(45),
                                                              IN in_fitness_trainer varchar(45),
                                                              IN in_fitness_address tinytext,
                                                              IN in_fitness_postcode varchar(10))
BEGIN

    set sql_safe_updates = 0;

    update tbl_user
    set updated_time	= now()
      , fitness_name    = in_fitness_name
      , fitness_trainer	= in_fitness_trainer
      , fitness_address    = in_fitness_address
      , fitness_postcode    = in_fitness_postcode
    where uid = in_user_uid;

    set sql_safe_updates = 1;

    call v1_proc_select_user_info(in_timezone, in_user_uid);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `v1_proc_update_user_logout` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `v1_proc_update_user_logout`(IN in_timezone varchar(45), IN in_user_uid int)
BEGIN

    set sql_safe_updates = 0;

    update tbl_user
    set updated_time	= now()
      , access_token 	= null
    where uid = in_user_uid;

    set sql_safe_updates = 1;

    call v1_proc_select_user_info(in_timezone, in_user_uid);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `v1_proc_update_user_nickname` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `v1_proc_update_user_nickname`(IN in_timezone varchar(45), IN in_user_uid int, IN in_nickname varchar(45))
BEGIN

    set sql_safe_updates = 0;

    update tbl_user
    set updated_time	= now()
      , nickname 		= in_nickname
    where uid = in_user_uid;

    set sql_safe_updates = 1;

    call v1_proc_select_user_info(in_timezone, in_user_uid);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `v1_proc_update_user_push_onoff` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `v1_proc_update_user_push_onoff`(IN in_timezone varchar(45), IN in_user_uid int, IN in_push_onoff int)
BEGIN

    set sql_safe_updates = 0;

    update tbl_user
    set updated_time	= now()
      , push_on 	= in_push_onoff
    where uid = in_user_uid;

    set sql_safe_updates = 1;

    call v1_proc_select_user_info(in_timezone, in_user_uid);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `v1_proc_update_user_pwd` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `v1_proc_update_user_pwd`(IN in_timezone varchar(45), IN in_user_uid int,
                                                          IN in_pwd_new varchar(45))
BEGIN

    set sql_safe_updates = 0;

    update tbl_user
    set updated_time	= now()
      , pwd 	= sha1(in_pwd_new)
    where uid = in_user_uid;

    set sql_safe_updates = 1;

    call v1_proc_select_user_info(in_timezone, in_user_uid);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `_dev_____v1_proc_select_contest_list` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`admin`@`%` PROCEDURE `_dev_____v1_proc_select_contest_list`(IN in_timezone varchar(45), IN in_user_uid int, IN in_is_my int)
BEGIN

    select _contest.*
         , convert_tz(_contest.created_time, 'utc', in_timezone) as created_time
         , convert_tz(_contest.updated_time, 'utc', in_timezone) as updated_time
         , ifnull(sum(_member.point), 0) as total_point
         , ifnull(count(_member.uid), 0) as join_count
         , ifnull(count(_team.uid), 0) as team_count
#          , (select v1_func_select_contest_total_point(_contest.uid)) as total_point
    from tbl_contest as _contest
             left outer join tbl_contest_team as _team
                             on _team.contest_uid = _contest.uid
                                 and _team.is_deleted = 0
             left outer join tbl_contest_member as _member
                             on _member.contest_uid = _contest.uid
                                 and _member.user_uid != in_user_uid
                                 and case when in_is_my = 0 then _member.user_uid != in_user_uid
                                          when in_is_my = 1 then _member.user_uid = in_user_uid
                                          else _member.user_uid != in_user_uid end
                                 and _member.is_deleted = 0
    where _contest.is_deleted = 0
      and _contest.start_date > now()
      and case when in_is_my = 1 then _member.user_uid = in_user_uid
               else true end
    group by _contest.uid
    order by _contest.start_date asc

    limit 100
    ;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2020-08-30 14:01:55
