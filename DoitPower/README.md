# DoItPower_Report

### 200821 DoItPower 서버 검토 및 준비
dotenv -> aws access key 나 비밀번호 계정 정보 등 팀원끼리 공유하지만 외부에 새어나가면 안되는 데이터를 .env 파일로 해서 보안해주면서 저장하는 도구        
> Npm install로 설치하면 될 것 같다.        
> Api 응답, 에러 처리할 때   

![image](https://user-images.githubusercontent.com/52439497/90869453-32e9a900-e3d3-11ea-810d-11061a1ce6ed.png)

> 이런 식으로 처리하면 좋을 것 같다. -팀장님 소스 참고     

##### <정리>
1. Error        
> 에러 발생 시 생성되는 error code를 따로 빼서 정리하는게 좋을 것 같다. Err code  파일을 따로 만들어서 module.export하면 될 것 같다.       
> error.stack -> 에러 발생 시 추적 정보를 담고 있다.         
> Error Util은 에러가 발생하면 가져오고, 에러를 초기화 하는 코드, 특정 상황에 대한 에러를 에러 메세지를 포함하여 생성할 때 필요한 코드, 마지막으로 throw error해서 에러를 던진다.   

2. hashUtil        
> 비밀번호 잃어버렸을 시에 랜덤으로 비밀번호 만드는 코드 !!!         
> Crypto 이용해서 진행하면 된다. randomBytes이용      

3. Mysql         
> 개발할 때 테스트 서버랑 실제 운영 서버를 다르게 해서 유지한다.        
> -> 사용자의 아이피를 가져와서 아이피가 실제 운영하는 아이피 주소인지 아닌지를 확인하여 실제 서버인지 아닌지 체크해준다.        


<pre>
query: async function (db_connection, query, params, resultCallback) {
    // console.log('query arguments.callee.caller : '+arguments.callee.caller.caller);
    if( !cf.isRealServer ){
        // console.log(`db_connection.state: ${db_connection.state}`);
    }
    if (db_connection && db_connection.state !== 'disconnected') {
        await db_connection.query(
            query,
            params,
            async function (err, rows, fields) {
                // try {
                if (err) {
                    // console.log(`==>>>>>>>>> err: ${err.message}`);
                    await resultCallback(null, errUtil.initError(errCode.system, err.message, err.stack));
                    // errorHandler( throwUtil.initError(errCode.system, err.stack) );
                    // throw err;
                } else {
                    // console.log('[INFO] ==================================');
                    // console.log('[INFO] fields : '+JSON.stringify(fields));
                    // if (resultCallback) {
                    await resultCallback(rows, null);
                    // }
                }
            });
    }
</pre>


> 이렇게 해서 굳이 파라미터 수로 함수를 나눌 필요 없다.       
> 또한 connection pool을 사용하는 경우,     
> Try, catch 를 이용해서 진행하는데 getConnection할 때   


<pre>
connectPool: function(asyncFunc, errorHandler){
    pool.getConnection(async function (err, connection) {
        try {
            if (err) {
                await errorHandler( errUtil.initError(errCode.system, err.message, err.stack) );
            } else {
                await connection.beginTransaction(); // 트랜잭션 적용 시작
                await asyncFunc(connection);
                await connection.commit(); // 커밋
            }
        } catch ( e ) {
            connection.rollback();

            console.log(`[${moment()}] Error connectPool start ==================================`);
            console.log(`[${moment()}] Error connectPool instanceof Error: ${(e instanceof Error)}`);
            console.log(`[${moment()}] Error connectPool e: ${e}`);
            console.log(`[${moment()}] Error connectPool e.message: ${e.message}`);
            let _stack = (e instanceof Error) ? '' : (e.stack ? e.stack : e);
            let _msg = (e instanceof Error) ? e.message : e;
            let _code = (e instanceof Error) ? e.code : errCode.system;

            let _err = (e instanceof Error) ? e : errUtil.initError(_code, _msg, _stack);
            // console.log(`[${moment()}] Error connectPool e: ${JSON.stringify(e)}`);
            // console.log(`[${moment()}] Error connectPool stack: ${e.stack}`);
            console.log(`[${moment()}] Error connectPool _err: ${JSON.stringify(_err)}`);
            console.log(`[${moment()}] Error connectPool end ==================================`);
            await errorHandler( _err );
            // sendUtil.sendErrorPacket()
            // throwUtil.call(_err.code, _err.message);
        } finally {
            console.log(`======>>>> connection.state(${connection.state})`);
            if( connection.state !== 'disconnected' ){
                console.log(`======>>>> connection release`);
                connection.release();
            }
        }
    });
},
</pre>


> 이렇게 구현하고 asyncFunc을 내가 mysql을 connect해서 진행할 기능을 넣으면 된다.       

4. nodeMailer       
> 이 모듈을 이용해서 사용자에게 메일을 보낼 수 있다.       

5. sendUtil         
> Sendutil 을 따로 만들어서 메일을 보내든, 서버에 에러를 보내든 보내는 부분에 대한 기능을 따로 빼서 진행     

6. 로그인  

![image](https://user-images.githubusercontent.com/52439497/90869768-a8557980-e3d3-11ea-9ff5-df45f81f59e0.png)

> 이런 식으로 로그인 사용자만 접근할 수 있는 api와 누구나 접근할 수 있는 api를 나누어서 api를 구성하는 것이 좋다.       
> 그래서 private인 api는 중간에 middleware를 설정해서 사용자를 확인할 수 있도록 한다.       
> app.all(‘/~ 이 부분에서 로그인을 확인할 수 있는 middleware를 설정한다.        

##### <팁>
1.  
> 사용자가 사용하다가 버그가 발생하면 어떤 운영체제에서, 어떤 앱 버전에서 발생했는지 알아야 쉽게 버그를 고칠 수 있기때문에 user table에 app버전이랑 os를 표시하는 column을 추가하는 것이 좋다.        
> 그리고 로그인 할 때마다 혹은 회원가입 할 때 사용자의 os와 앱 버전을 새로 수정하는 것이 좋다.        

2. 
> nodemailer를 이용해서 서버에서 메일을 사용자에게 전송을 할 수 있는데, 이 때 에러가 발생한다.           
> 대부분 에러는 보안 이슈 때문인데, 보내고자 하는 메일의 보안을 낮추면 메일을 서버에서 대신 전송할 수 있다.         

3. 중요한 api를 전송하거나 그런 경우는 log를 따로 기록해놓는 것이 좋다.      

4.       
> Update 를 시작하기 전에 set sql_safe_updates = 0; 이 명령어를 진행해서 safe update mode를 끄는 것이 좋다.        
> 그리고 update를 다하면 set sql_safe_updates = 1; 를 해서 원상복구 해야한다.        

5. Table 간 join! Inner join과 outer join이 존재한다.         
> 여기서는 내가 참여하는 contest 목록을 가져올 때 contest member 테이블이랑 contest team 테이블과 각각 join해서 내 uid랑 맞는 contest를 가져온다.         

6. Mysql ifnull(값, 대체할 값)         

7. 
> AWS S3에 사진을 올릴 때, 해당 파일의 mimetype.startWith 를 이용해서              
> 이미지라면 ‘image/‘로 시작하는지, ‘audio/’ 이런 식으로 시작하는지를 통해 파일 유형을 알아낼 수 있다. => fileFilter 로 해서 multerOptions을 만들고 거기에 넣을 수 있다.       


![image](https://user-images.githubusercontent.com/52439497/90870008-f8ccd700-e3d3-11ea-8b66-c757051e7b89.png)

8. 
> Node에서 이미지 처리에 sharp 모듈이 유명           
> 이미지 resize, 확장, 이미지 추출, 이미지 처리 등 이미지를 사용할 때 유용한 라이브러리이다.            
> 특히 한 이미지에 대해서 썸네일 사진이 필요한 경우,  원본 이미지를 resize 시켜서 따로 섬네일 사진을 만드는 것이 좋다.        


### 200824 DoItPower contest api 구현 시작
Contest 상세 페이지 가져올 때, db procedure를 보완하였다.         
> contest_detail 작성      

![image](https://user-images.githubusercontent.com/52439497/91280802-3f4e7700-e7c2-11ea-8bfc-1bb8a6d4325c.png)

> Left join은 left outer join을 의미하는 것과 같다.       

![image](https://user-images.githubusercontent.com/52439497/91280904-67d67100-e7c2-11ea-9b4b-9d3b70df45f0.png)

> 이런 식으로 join의 결과가 등장한다.       

![image](https://user-images.githubusercontent.com/52439497/91280981-80df2200-e7c2-11ea-8591-f457b40daf4d.png)

> 여러 개의 테이블에 대해서 join을 여러개 하고자 한다면, 이렇게 진행하면 된다.          
> Contest  상세페이지에서 보여줄 상태를 보여주기 위해 db procedure이 아닌 db function을 만들어 구현해보았다.         
> 또한 function을 만들때 다른 테이블에서 정보를 가져와야 하기 때문에  join에 대해 공부하고 구현해보았다.             
> 또한 서버와 디비 측 오류를 수정하였다..          


### 200825 대회 경우의 수 파악하고 상세 정보 및 참여 현황 db query 작성
1. Contest 상태 보여주는거 마저 완성 하기 (완료)         
> 참여하고나서 인원 미달인 경우 와 인원이 다 찬 경우 경우의 수 추가        

2. 우승 예상 상금 계산하는 로직 구현하기            
> -> 참여 전인 경우와 참여 후인 경우 나누어서 우승 예상 상금을 구현한다.            
> -> 상금 수령자의 총 참여금이랑 수수료 제외한 총 금액               
> -> 참여하고나서 참여 인원 모집중일때는 참여인원미달로 우승예상금액을 표시하지 않음             
> -> 상위 30%를 계산해야한다. (완료), 참여 현황 계산 완료    

3.  참여 현황 확인하기                

##### <팁>     
1. join해서 order by 하는 것보단 join하는 테이블을 먼저 order by한 후에 join을 하는 것이 성능이 더 좋다!            
2. Select 문에서 변수에 값을 대입하고 싶을 때, 
<pre>
select fitness_reward_rate, fee_rate into fitness_rate, fee_rate from tbl_contest where uid = in_contest_uid;     
</pre>
> 이렇게 해야한다.            
> Select fitness_reward_rate into fitness_rate, fee_rate into fee_rate 이런 식으로 하면 mysql 1415 에러 발생한다.            
> 상위 30%를 알기 위해서 제일 처음에 한 인증 데이터와 제일 최근에 한 인증 데이터를 가져와서 각 value의 차이를 계산하는 procedure           

> —> 애매한 부분 : tbl_certify인데 여기서 굳이 max 데이터랑 min 데이터를 join을 할 필요가 있는가          
<pre>
CREATE DEFINER=`admin`@`%` PROCEDURE `select_calculate_grade_not_count`(
	IN in_contest_uid int
)
BEGIN
	select _certify.*
		, if(_max.user_uid = _min.user_uid, _max.value - _min.value, NULL) as difference
        from tbl_certify as _certify
			/* 해당 대회에서 user uid 마다 제일 처음 인증한 데이터 가져오기*/
			left join (select * from tbl_certify
							where uid in (
							select distinct MAX(uid) 
								from tbl_certify 
                                group by user_uid
							) order by user_uid DESC ) as _max
            on _max.contest_uid = in_contest_uid
            /* 해당 대회에서 user uid 마다 제일 최근에 인증한 데이터 가져오기*/
            left join (select * from tbl_certify as _min
							where uid in (
							select distinct MIN(uid) 
								from tbl_certify 
								group by user_uid
							) order by user_uid DESC) as _min
            on _min.contest_uid = in_contest_uid          
		where _certify.contest_uid = in_contest_uid
			/* 최대, 최소 user uid가 같은 경우만 갖고오기 안그러면 다른 데이터들도 가져온다.*/
			and _max.user_uid = _min.user_uid
            /* 해당 user uid랑 max 또는 min user uid가 같은 경우만 갖고오기 안그러면 다른 경우 데이터들도 가져온다 */
            and _certify.user_uid = _max.user_uid;
END
</pre>
       

### 200826 참여 현황 정보 확인 & 참여 현황 상세 정보 DB QUERY
1. 사용자 별 등급을 부여한다.(완료)          
2. 개인전, 팀전 나누지 않고 참여 현황을 알 수 있는 db query 작성 완료.         
3. 화면이 바뀔 때 마다 api를 새로만들면 된다.!!!!!! (참여 현황 구하는 api 완료)          
4. 개인전이랑 팀전이랑 나눠서 생각하지말자. 하나의 db query와 api를 이용해서 만들어보자.           
5. 파라미터는 최소로 간단하게 하면 된다. 참여 현황의 경우도 contest uid를 이용해서 진행할 수 있도록 한다.          

dense_rank -> 중복 되는 데이터의 랭킹을 동일하게 생각하여 랭킹을 계산하는 mysql 함수          
Over -> order by 랑 group by를 더 효과적으로 진행할 수 있도록 도와주는 mysql 함수           
DB 쿼리는 최대한 간단하고 최대한 합칠 수 있으면 합쳐서 같이 사용하는 것이 좋다.           

> 대회 참여 현황을 알아볼 때 사용자가 참여한 경우, 사용자가 대회에 참여한 경우에만 참여 현황을 볼 수 있기 때문에 private 경로로 구현하였다.         
> 또한 각 대회의 victory_type에 따라 참여한 사람들의 등급을 계산하는 방법이 다르기 때문에        
> 대회 uid를 이용해서 대회의 victory type을 알고 각 victory type에 따라 procedure를 달리 실행하는 procedure를 하나 새로 만들었다.            
> 그리고 참여 현황을 보여줄 때 사용자 이름을 보여줘야 하는데  이렇게 하려면 team, member, user 이렇게 테이블을 타고 들어가야한다.            
> 그래서 테이블 사이에 join을 해서 팀의 멤버를 파악하고 멤버들의  user uid를 통해 user 테이블에서 닉네임을 가져오면 된다. (완료)          
—> 정리 필요 !

### 200827 대회 참가 신청 api 구현
-> 팀으로 참가하는 경우 기존에 있는 팀을 신청할지, 신규 팀을 생성할지를 알고 정해야한다.       
-> 파라미터는 대회 uid, 팀명, 비밀번호가 필요하다. 신청 한번 할 때마다 team count 증가하고 만약 team count가 2가 되면 모집 완료로,  team 이 모집 중이라면 1로 표시하면 된다.       
—> 개인전인 경우 team count 1로 하고 모집완료 상태로 정해놓으면 된다.       
  > 앞에서 오는 파라미터가 “”인 경우 null로 변환해서 query를 부른다.        
—> 근데 team count -1인 경우는 인원 미달이라는 의미던데 이거는…? 언제 체크해서 변경하는게 좋을까..?         
> 팀명은 중복이 안되는 것으로 처리한다.           
-> 팀의 리더는 처음 만드는 사람이 리더가 된다.               

> 개인전이든 팀전이든 대회에 참가하면 포인트를 차감해야한다.            
> -> 잔여 포인트 계산: tbl_point에서 충전된 포인트 + 적립된 포인트 - 사용한 포인트 - 환급된 포인트 - 환급 예정인 포인트             

##### Api 설계
1. 개인전이면서 신규 팀 가입인 경우는 굳이 클라이언트 개발자에게 포인트를 알려줄 필요가 없으므로 그냥 포인트 클릭만 하면 check하고 팀 생성하는 로직 작성              
2. 기존 팀 가입인 경우는 포인트를 먼저 알려주고(api 한개) 그리고 포인트를 클릭을 하면 check하고 기존 팀에 가입하는 로직 작성                
> Api parameter 체크는 팀전인 경우에 team name, pwd가 null인지 체크해야한다.              

#### <이슈>
Mysql 에서 @을 이용해서 변수를 declare하지 않고 사용하면 이전에 한 정보가 그대로 담겨있었다.              
변수처럼 새로 선언되고 그런 것이 아니라서 그런지 프로시저를 계속 호출해도 계속 값이 저장되어있고 바뀌지 않는 것 같다.             
그래서 declare로 변수를 선언하고 사용하였더니 변수 값이 프로시저를 호출할 때마다 초기화되어 바뀌었다.              
또한 parameter 혹은 body에 0을 하면 파라미터 체크 시 파라미터가 없다고 파악된다. 따라서 파라미터로 status, type 같은거 정할 때 0은 피해서 하는 것이 좋다.              

> -> 다음 할일 : contest 참여 취소 & point  계산 변수 declare해서 사용 @ 사용하지말고         

### 200828 대회 참가 신청 api 보완 & 대회 참가 취소 api 구현 
- Contest 참가할 때 포인트 계산이 제대로 안됐는데, 이 때 sum을 select해서 구할 때, null값이 나올 수 있으므로 ifnull해서 null이면 0으로 대체할 수 있도록 해야한다.        
> null이면 계산이 제대로 이루어지지 않는다.       
- 개인전의 경우 team_name과 team_pwd가 “” 으로 오기때문에 이를 null로 변경해서 나중에 tbl_contest_team에서 중복체크할 때 이슈가 되지 않도록 하였다.          
> 중복체크할 때 null인건 제외하고 중복체크하면 되기 때문이다.         
- 대회에 참가가 완전히 이루어진 경우 tbl_point에 사용한 기록을 남겨야한다.             
- 진행중이지 않은 대회의 참가 현황을 알려줄 때, 사람들의 이름이랑 등급을 1로해서 query를 수정해야한다.               
- 대회 참가 취소할 때, member 정보 삭제해야하고, team 정보도 팀원을 줄이고, point 정보도 삭제해야한다.       
> 이 때 팀원이 0이 되면 팀 정보를 삭제한다. 대회가 진행 중인 경우 참가 취소를 할 수 없기 때문에 tbl_certify 데이터는 삭제 처리를 하지 않아도 될 것 같다.           
- 참여 현황 보여줄 때 해당 유저가 참여하고 있는지 여부를 보여주고, 내가 속한 팀인 경우에만 비밀번호를 보여줄 수 있도록 한다. (참여 여부는 보여줬지만 비밀번호는 구현할 수 있을 것 같은데 못함)             
- 삭제 하는 경우 팀전일 때 대회가 진행 전이라면 모집 전 상태로 변경해야한다. 인원이 줄면서(완료)       


#### <이슈>
-> null as 를 사용해서 pwd 같은 것을 null로 해서 안보여줄 수 있는데, 이상하게 join하고 그런 부분에서는 중복되는 column이라고 에러가 발생했다.           
> 근데 제일 바깥에 있는 select 문에서는 에러가 나지 않았지만 중복된 이름의 column이 등장하였다.          
> 그래서 그냥 pwd 부분만 따로 처리를 해주었는데 다른 해결 방법이 무엇인지 찾지 못하였다.          
-> mysql에서 select 한 값을 변수에 할당할 때 변수 이름을 select 해서 얻은 데이터의 column값과 동일하게 하면 원하는 결과가 제대로 나오지않는다. 아마 겹쳐서 그런 것 같다. 주의하자             
-> join을 한 경우에 member 의 user.uid가 제대로 안나오는 것을 발견했다. 결과는 제대로 나오는데 join하고 그런 것에 대해서 문제인 것 같다.     
==> join을 할 때 잘못한 것 같다. 수정하면서 진행하다보니 join 부분이 잘못되어 원치 않는 결과가 등장한 것 같다.             

> 다음 할일 : 삭제할 시 status 변경하는 것(함) , 비밀번호 찾아보자        


### 200831 

- contest 내 페이지에서 취소된 여부를 알려줘야한다. 왜 취소된 것인지 이유랑 함께 알려줘야한다. (완료)        
- 참여 상세페이지에서는 등급이랑 랭킹? 비율을 procedure를 따로 실행시켜서 결과를 얻고 client에 알려주는 것이 좋다. (완료)          
- 팀 table의 team count는 최대 인원을 의미한다. 팀 취소된 경우 수정하자 (완료)                

#### <할 일>
- [ ] 나중에 캘린더 탭에서 해당 날짜의 인증 정보를 가져오는 경우 해당 날짜의 인증 정보들을 가져오면 된다.           
- [ ] my list에서 상태 보여주는건 했는데 상태 보여주고 나서 팀원 미달인 경우 team status를 변경하는 작업 해야한다.              

#### <배운 점>
- 취소하는 procedure를 수정을 하였다. team_count는 최대 팀 인원이다. 현재 팀원 수가 아니다. 따라서 그에 맞게 취소하는 procedure을 수정하였다.             
이 때 실제 팀원 수를 구하기 위해서 member 테이블 select 문의 where 문에서 contest_team_uid = ( 서브쿼리) 이런 식으로 구현하여 남아있는 팀원 수를 구하고 변수에 저장하였다.               
join으로 구현하고 싶었지만 할 수 있는 방법이 떠오르지 않아서 일단 서브쿼리로 구현을 하였다. 다른 테이블인 경우라면 할 수 있을 것 같은데 같은 테이블이기 때문이다...              

#### <이슈> 
- 이전에 구현해놓은 등급 가져오는 query에서 contest_uid의 변화에 따라 달라지지 않고 계속 결과를 가져오지 못하는 경우가 있었다. 보니까 최소값을 가져오지 못하는 것을 확인하였고,            
 
 <pre>
left join (select * from tbl_certify as _min
		where uid in (
			select MIN(uid)									
			from tbl_certify 
                        where contest_uid = 3
			group by user_uid
		) order by user_uid DESC) as _min
		on _min.contest_uid = 3
		and _min.is_deleted = 0
		
</pre>

이 부분에서 where in ()의 subquery에서 where contest uid해서 조건을 추가하였더니 원하는대로 결과가 등장하였다.      
그리고 min의 경우 제일 오래된 데이터를 가져오는 것이고 max의 경우 제일 최근 데이터를 가져오는 것이다.       

- 대회 status를 구할 때, when case를 사용해서 조건에 따라 status를 나누는데, 이게 순서대로 작동을 해서 참가 모집 중, 후 로 나눈 후에 진행 불가능한 조건들은 앞으로 가고 이 진행 불가능한 조건을 다 통과하고 나서 뒤에 진행 가능한 조건을 두면 불가능한 상태들을 다 필터링 할 수 있다. 그리고 if를 사용해서 팀전인 경우랑 개인전인 경우랑 status 확인하는 방법을 하나의 function으로 합쳤다.            
 
### 200901
- 인증 정보 삭제 api      
- my list에서 상태 보여주는건 했는데 상태 보여주고 나서 팀원 미달인 경우 team status를 변경하는 작업 해야한다.        
- 이의제기 요청 api,         
- 이의제기 요청과 이미지 api를 반영하여 인증정보가져오는 query 수정        
- 인증 정보 생성 api          

#### <배운 점>
- DB에 중복 선택에 대해서 비트 연산을 이용해 표시를 한다. 정말 몰랐던 점인데 배울 수 있었다. 예를 들어서 1번 2번을 선택하면 0000 00011 이런 식으로 1,2,4번을 선택하면 0000 0111, 1,2,4,8번을 선택하면 0000 1111 이런 식으로 비트 연산을 통해서 표시할 수 있다.                  
https://www.phpschool.com/gnuboard4/bbs/board.php?bo_table=tipntech&wr_id=77064&page=26

- 이미지 업로드를 하는 경우에는 한번에 여러 이미지를 업로드하는 것을 생각할 수 있지만 그게 더 빠르지만 여러명이 한번에 여러 장의 사진을 업로드하다면 서버가 터질 가능성이 완전 높아진다. 서버 과부화가 최대한 이루어지지 않도록 하기 위해서 이미지를 한번에 한개씩 보내고 처리하는 것이 좋다. 그리고 이미지는 이미지를 관리할 수 있는 이미지 테이블을 만드는 것이 좋다. 이미지 이름과 업로드한 유저의 uid, 어디에 쓰이는지 이미지 타입과 해당 이미지가 어떤 데이터와 매치가 되는지 등의 정보를  담고, 나중에  이미지 테이블을 join해서 이미지 이름 를 가져오면 된다.                 
- 데이터베이스를 개발서버에서 진행하다가 테스트 서버에 배포해야하는 경우가 있다. 이런 경우를 db 배포라고 하는데, 아직 제대로 된 방법이 나와있지 않다. 그래서 팀장님 의견으로는 테이블 컬럼이 추가된 경우 개발 서버랑 테스트 운영 서버를 비교해서 하나하나 추가하고, 테이블의 경우는 if exist를 사용하면 안된다. 그러면 데이터가 다 날라간다. 그리고  procedure, function의 경우는 if exist를 사용해서 실행시키면 된다.              

### 200902 
- 개발 서버 rds의 데이터베이스를 테스트 운영 서버 rds에 배포하였다. 찾아보니 dump 같은 방법 밖에 없는데 dump를 하면 기존에 있던 데이터들이 사라지고 새로운 데이터가 생기는 것이기 때문에 사용하기 힘든 방법이다. 그래서 일단은 하나하나 확인하고 데이터 export, import해서 구현을 하였고, routine의 경우는 데이터가 있거나 그러지 않으므로 그냥 if exist해서 있으면  drop해서 새로 만든 routine을 적용하도록 한다. 이 때 중요한건 DB 백업이다.               
- Mysql date, timestamp type처럼 날짜를 표시하는 column의 경우, MONTH(날짜데이터), year(날짜데이터) 이런 식으로 하면 연, 월, 일을 추출할 수 있다.               
- Timestamp column의 날짜를 검색하는 방법은 timestamp를 datetime으로 변경하고 입력 받은 날짜도 datetime으로 변경하면 된다.         
<pre>
select * from tbl_certify where DATE(created_time) = DATE("2020-08-25"); 
</pre>

- 캘린더에서 보여지는 인증 정보랑 내 인증 정보 목록을 날짜별로 검색하는 api 구현       
- 대회 상세 보기하는 경우 팀원 미달 이런거 원인 보여줘야한다. (완료)          
- 내 인증 목록에서 대회 이름도 들어가야한다. (완료)            
- 내 인증 목록에서 이의제기 내용도 들어가야한다. (완료)            
- 참여 현황에서 ranking을 기반으로 해서 등급을 계산함.(완료)           

#### <배운점>
- 컨트롤 옵션 i 해서 줄맞추고, insert 같은거 중복으로 쓰인다면 따로 procedure로 빼서 call하는 형식으로 진행한다. 그리고 중복 계산처럼 계산하는 부분은 function을 사용해서 진행한다. 줄 수는 최대한 줄이자   
- DB 쿼리 코드 정리      
-> 최대한 정리하자            
변수의 경우 v_~       
파라미터의 경우 in_        
join은 중복되는거 최대한 줄인다.           
그리고 개인전, 팀전 나눠서 랭킹(참여 현황) 계산하는 query 나눠서 작성        
그리고 이때 개인전인 경우, 팀전인 경우 내가 참여한 팀, 내 정보에 대해서 따로 query를 만들어서 진행한다. 그리고 팀전인 경우 팀원 이름을 배열로 해서 string으로 concat이용해서 {} 배열로 넣어서 서버에서 json으로 만들고 client에 보내준다.         
대회 status 정리해서 status에 대해서 function 생성          
취소 이유에 대해서 알려주는 function 생성         
     

<pre>
대회 상태
status: 모집중, 진행중, 취소, 종료

대회 모집 완료후 취소된 경우 이유
canceled_type: 인원 미달, 팀원 미달

대회 참여신청할때 처리
limit_max: 최대 인원
</pre> 


### 200903
- Ranking count 인 경우 자기 팀이 아니면 안보이게 하고, 다른 팀인 경우 팀 유저의 이름을 concat으로 해서 배열로 한 column 안에서 보여줄 수 있도록 하였다. 또 right join으로 가져올 때 제대로 가져오지 않아서 이를 수정하였다.                  
- 포인트 가져오는거 중복으로 가져오는거 해결해야한다.  -> 상금가져올때 필요하다고 했는데… 흠… 이를 참여현황 보여줄 때 해야하나 그 때 하지말고 우승 예상 상금을 따로 구하는 쿼리를 작성하는 것이 맞을 것 같다. 참여현황에서 보여주는 것이 아니라               
- 팀전 참여 현황 이미지는 팀 리더의 이미지로 보여준다.                   
- Down 의 경우, 내가 속한 팀인지 아닌지를 나누고 보여주도록 하였다. 내가 속했는지 속하지 않았는지를 알려주었다. Up의 경우도 down 랭킹을 구할 때 정렬을 반대로 하면 되기 때문에 바로 구현할 수 있다. 근데 up이랑 down을 나누지 않고 그냥 분기시켜서 한 query로 할 수 없나              
-  내가 참여하고 있는지 없는지 여부는 굳이 db 에서 확인해줄 필요가 없고 api 요청오면 내가 참여한 팀에 대해서 query, 참여안한 팀들에 대해서 query해서 api 하나당 여러번 query를 진행해야겠다.             
 
### 200904
DoItPower
—> contest에서 up인 경우는 많이 올라갈수록 좋은 것이고,  down인 경우 많이 적을수록 좋은 것이다.               
=>  down인 경우 제일 처음 - 최근 이것이 클수록 좋은것             
=>  up인 경우 최근 - 제일 처음 이것이 클수록 좋은 것               
- Member 몇명인지 count하는거 팀인지 싱글인지 나눠서 카운트할 수 있도록 (완료)               
- ranking 구하는거 single  (up, count, down) 구현               
- Ranking my single 구현            
- Contest 상태 관리하는거 구현            

#### <이슈>
- Mysql join 하는 경우 if 문에 따라서 진행을 할 수 있는 것인가.                        


### 200905                 
- doitpower 대회 상태 정리               
- doitpower 팀 비밀번호 암호화하기               
- doitpower 참여 현황 정리해서 팀/개인전, 내가 참여했는지 아닌지, 인증 정보가 하나도 없는 경우                 
- Team ranking 구하는 경우 nickname뿐만 아니라 uid도 같이 group concat해서 보내줘야한다.              

랭킹 구하는거 자세하게 알아내자. 랭킹 구할 때 인증을 아무것도 안한사람도 랭킹 계산하는데 포함 을 해야하는지 알아야한다.               

##### 데이터 암호화 방법
근데 sha1로 암호화하면 안된다. 단방향이기 때문에 복호화를 할 수 없다. 따라서 쌍방향 암호화로 하지. 팀 비밀번호 같은 경우 사용자에게 알려주어야 하기 때문에 .               
  
단방향 암호화	- MD5, SHA1 같은 방법으로 암호화(Encrypt)후 원래대로 복호화(Decrypt)가 필요없는 경우 - EX) 패스워드, 주민번호(복호화 불필요시) 등               
쌍방향 암호화	- DES, DES3, ENC, COMPRESS 같은 방법으로 암호화(Encrypt)후   원래대로 복호화(Decrypt)가 필요한 경우 - EX) 이름, 아이디, 주민번호 (나이계산, 생일), 메일주소, 주소,닉네임, 나이,생일 등             
 
출처: https://sopie2000.tistory.com/10 [Nothing can be done without efforts.]                 
 
단방향 암호화만 지원  
- MD5, PASSWORD. SHA1, SHA              

쌍방향 암호화 (암호화,복호화) 지원
- AES_ENCRYPT ,AES_DECRYPT  - DES_ENCRYPT ,DES_DECRYPT  - DECODE, ENCODE              


출처: https://sopie2000.tistory.com/10 [Nothing can be done without efforts.]              

### 200907
- 인증 정보 알려줄 때 certify 값 계산하기                
- 참여 현황 랭킹 반올림               
- 사용자 포인트 정보(내역)             
- 참여 현황 알아볼 때, 팀전이랑 개인전 데이터 형태 맞추기             
- 인증 정보 정리             

### 200908
- test하면서 오류 찾아내기           
- 사용자 프로필 제공하는 api 추가               
- 사용자 레벨 계산하는 function 추가                 
- 인증 정보 삭제하면 이미지 테이블에서 인증 사진 삭제하는거               
- 인증 정보 삭제했을 때 이의 제기한 정보도 삭제해야하나? 나중에 관리자 페이지에서 관리할 때 보이면 안되는 것이니까..?            
- 취소하면 포인트 사용한거 삭제하기 -> procedure은 만들었는데 언제 사용할지.. 정확한게 아ㅣ니라 pass            
- Swagger api 명세서 정리하기             

### 200909
- Contest 상태 보낼 때 한글말고 영어나 숫자로 해서 표시를 한다.              
- Participation 계산하는 경우 min, max 중복해서 가져오는 것이 느릴거같아서 성능 속도 개선할 방법 찾기          
- Contest 상태 변경하기                   
> status : 0 - 신청중, 1 - 진행중, 2 - 취소, 3 - 종료               
> cancel type : 0 - 취소 이유 없음, 1 - 인원 미달, 2 - 팀원 미달              
- 팀 리더가 대회 참여 취소한 경우 팀 전체가 참여 취소할 수 있도록 한다                 
- proc_contest_team -> 이 부분 상태 변경한거 코드 추가해서 수정해야한다.                
- Swagger 상태 정리 설명 추가 & api 설명을 path 있는 곳으로 빼기                
- 만약 인증 정보가 삭제된다면 count의 경우 하나 줄이고, up, down인 경우는 값을 다시 계산해서 원상복구 하도록              
- 참여 현황에서 랭킹 계산하는거 인증이 들어올 때마다 계산을 할 수 있도록                
- up down인 경우는 제일 처음 값이랑 인증 들어온 값이랑 차이 구해서 계산을 하면 되고 count인 경우 +1 한다.                
- 인증 값 필드 추가해서 랭킹 계산하는 쿼리 새로 작성                 
> 인증 값이 추가될 때마다 제일 처음 인증 값과 현재 추가하는 인증 값과 차이를 구해서 인증 값의 차이를 구해서 certify-value에 값을 삽입한다.     
> 그리고나서 개인전, 팀전 상관없이 유저가 속한 team uid와 같은 팀의 멤버들의 certify_value를 다 더하고 팀원 수로 나눠서 team table의 certify_value를 갱신해준다.                     
> 후에 certify_value를 이용해서 랭킹을 계산하면 된다.         
> 이 때 certify_value의 초기값을 0으로 해서 인증 정보가 아무것도 없는 처음 상태에서 certify_value가 모두 0이라서 ranking 계산 시 모두 0으로 계산할 수 있다. 즉, 따로 진행 안한 경우에 랭킹을 계산하는 프로시저를 구현하지 않아도 1등급으로 보이기 때문에 된다.                         
> 그리고 인증 정보가 추가될 때마다 victory type에 상관없이 인증 필드를 계산하기 때문에 (count인 경우는 +1해서 늘린다.) victory_type에 따라 프로시저를 나누지 않아도 된다.                   
> 이렇게 하니까 참여현황을 볼 때마다 인증 값을 구할 필요가 없어서 쿼리가 훨씬 간단해진다.                    
- contest category는 한글인 경우 영어로 바꿔주는 작업이 필요하다.                  



### 200910
- Db procedure, function name 변경한거 server 에 적용                  
- 이미지 업로드할 때 이미지 데이터 삽입하는거 query                   
- proc_delete_contest_member 이거 정리                     
- 팀 패스워드 복호화 부분 hex 빼기        
> aes_encrypt 이용하면 바뀌는데 그 형태가 blob형태라서 pwd 를 blob형태로 저장하거나 그래야한다. 
> 이 때 hex는 암호화 용도가 아니라 문자열로 변경해주는 역할이라서 hex를 이용해서 blob을 문자열로 변경해서 저장하는게 좋을 것 같다.                  
- 대회 참가할 때 팀 정보 갖고 오는 경우 null as pwd 하기   

<pre>
-> 복호화 : cast(AES_DECRYPT(team_ranking.pwd, 'doitpower') as char(100)) as pwd         
-> 암호화 : aes_encrypt(in_team_pwd, 'doitpower')
</pre>

- Db query는 최대한 간단하게 여러 기능을 한 프로시저로 때려박는 것이 아니라 최대한 나눠서 진행하고 이 프로시저를 또 한 프로시저 안에서 여러번 보이게 하는 것이 아니라 서버 쪽에서 그 프로시저를 호출하는 것이 좋다.  > 왜냐하면 디비에서 쿼리로 다 때려서 박아놓으면 에러를 확인하기가 힘들고 에러 발생시 원인을 설명하는게 까다롭다. 그래서 최대한 기능을 분리하는 것이 좋다.              
> 예를 들어서 팀 생성하는거, member 생성하는거 따로 프로시저를 분리해서 진행하면 된다.                  

#### <배운 점>
<pre>
return mysqlUtil.queryArray(db_connection
    , 'select func_select_certify_value(?,?) as value' 
    , [
        req.paramBody['contest_uid'],
        user_uid,
    ]
);
</pre>
Mysql function을 사용하는 경우 return value의 이름이 function 이름으로 나와서 value를 가져오기 힘든데, 실행하는 query에 as ~를 써서 원하는 별명으로 가져오면 된다.              

### 200911 
- contest 취소한 경우 procedure 정리         
- Contest team status 팀원 미달인 경우 -1로 변경할 수 있도록  -> 어디서 어떻게 해야할지 감이 잡히지 않는다…              
- 프로필 사진 수정하면 기존 사진은 삭제하고 추가할 수 있도록 한다.          
- Db procedure name 변경된거 server 코드에 적용하기              
- 이미지 업로드할 때 이미지 데이터 삽입하는거 query            
- member가 대회 참여 취소한 경우 인증 값 삭제하기             
- proc_delete_contest_member 이거 정리           
- Db 팀 패스워드 암호화 다시 하기           



### 200914 doitpower node schedule을 이용하여 fcm 알람 전송할 수 있도록 
<DoItPower>
- 팀 비밀번호 암호화할 때 어떤 key를 사용할지 고려      
- Fcm 을 이용해서 Push 생성을 위해서 뭐가 필요한지 swagger에 나타나기        
- Push 보낸 요청에 대해서 로그 테이블을 만들어서 냅두기 -> 보낸 시간 가튼거.. 관리자 페이지에서 필요한 거 뭐있는지 살펴보기      
- 스토리 보드 보면서 어떤 push가 필요한지       
- 소스 코드 좀 정리하기      
- 만들지 않은 api 있는지 확인하기     
> 사용자 대회 목록에서 등급을 알려줘야한다.          
- 데이터베이스 프로시저랑 테이블 올리기 그리고 필수 데이터 아니면 올리지 말기      
- api 서버에 올리기     
- api서버 버전에 대해서 알아보기 -> 버전관리가 어떤것이 필요한지 알아보기          

의논할 부분
- 우승 예상 상금 계산
- 포인트 충전하는 경우에 어떻게 해야하는지..?
- 환급같은거 요청할 때 사용자 계좌번호는,,,? 이거 기록을 따로 남겨야하나 

=>  대회 상태
	•	0 : 모집중
	•	1 : 진행중(취소랑 정상적인 진행 둘다 포함)
	•	2 : 종료
대회 취소 이유
	•	0 : 취소 아님
	•	1 : 인원 미달
	•	2 : 팀원 미달 이렇게 표시하는건가..?


==> 취소인 경우를 대회 상태를 굳이 따로 표시할 필요가 없다 

###### <관리자 페이지에서 필요한 API>
1. 관리자가 이의제기를 승인한 경우, 이의 제기가 반영된 인증 정보는 반영되면 안되기 때문에  member table, team table에서 인증 정보를 다시 업데이트해서 새로 계산할 수 있도록 한다.                
-> 인증 값 계산할 때 objection도 반영해서 계산할 수 있도록 함                 

###### <Push 알람 목록 (알림 설정 유무도 있다.)>
- 대회가 시작된 후에 대회 정보(진행 중인지 취소됐는지)를 확인하라는 알람 => 이 경우에는 각 대회마다 topic을 정해야하는 것인가 ..?                  
- 반대로 종료된 경우에도 종료에 대해 푸쉬 알람              
- 환급 완료 이런거는 환급이 완료되었습니다 이런 식으로 알람오는 것이 드물어서 안해도될 것 같다.           
- 포인트 적립에 대해서는 알람을 줘야하나..? ~~ 포인트 적립 완료 이런 식으로(근데 이게 우승예상상금이긴한데…)               
- 나의 인증 정보에 대해서 이의 제기가 들어오고 관리자가 이의제기가 있다고 한 경우 ? 에 알람을 보내야하나 /                
- 팀전인 경우 내가 만든 팀에 새로운 인원이 들어왔을 때..? 팀원이 추가되었다는 알람 =? 이 경우는 팀마다 topic을 정해서 보내야하는 것인가 아님 그냥 token을 이용하는 것인가 …              
- 게임처럼 새로운 대회가 등록된 경우에 알람을 보내나..?               
- 그리고 주 당 몇회 인증이 있는데 아직 몇 번 인증을 못하였습니다. 라는 알람도 보내야하나..              
- 광고 알람…? 애니플처럼 광고 알람을 보내는것..?                   

### API 버전 관리 
/api/v3/greetings // 서비스 수준               
/api/v3/greetings/v3.1/hello // 서비스 단위 및 기능 수준              
/api/v3/greetings/v3/hello // 기능 수준               

이런 식으로 restful api의 버전 관리가 가능하다.             

#### API에 버전을 지정하는 방법
1. http 헤더를 변조하여 버전 정보를 추가하거나 미디어타입 변경. (Accept: application/v3+json)               
2. url path에 추가함(http://google.com/v1/search)                  
3. url 파라미터로 추가함 (http://google.com?v=v1)                

#### Package.json을 이용해서 API 버전관리를 진행하는 방법
https://cheese10yun.github.io/packageFile-API/
![image](https://user-images.githubusercontent.com/52439497/93751185-a59aae00-fc37-11ea-823b-64f34ea44303.png)

![image](https://user-images.githubusercontent.com/52439497/93751196-a7647180-fc37-11ea-9e3a-0771d58205c5.png)

#### API 버전 관리할 때 버전 표기법
https://m.blog.naver.com/PostView.nhn?blogId=youngchanmmm&logNo=220752702977&proxyReferer=https:%2F%2Fwww.google.com%2F      

핫픽스 카운트의 핫 픽스 hotfix        
-> 핫픽스(Hotfix)란?           
제품 사용 중에 발생하는 버그의 수정이나 취약점 보완, 또는 성능 향상을 위해 긴급히 배포되는 패치 프로그램              

출처: https://tttsss77.tistory.com/57


![image](https://user-images.githubusercontent.com/52439497/95009515-ac74e800-065d-11eb-9b14-871948bf3c0d.png)

![image](https://user-images.githubusercontent.com/52439497/95009517-aed74200-065d-11eb-8ae8-7085efcd04c0.png)

![image](https://user-images.githubusercontent.com/52439497/95009519-b1d23280-065d-11eb-9cad-e2b31d999431.png)


### 200915
- DoItpower startling rds로 잘 돌아가는지 서버에서 확인 private ip를 내 아이피로 설정한다음에 확인하면 될 것 같다.       
- Doitpower 주기적으로 실행할 수 있는 node-schedule 사용해보기          
- Doitpower 이거 log table 에 user os, 앱 버전을 클라이언트에서 받아오는 api 만들기            
- User table에 os, 앱 버전 필드 지우기 (로그 테이블 -> user UID, created time, updated time, is_deleted 필요없을 것 같은데 일단 넣어놓고, os , 앱 버전)           
- Doitpower push 알람 종류에서 이벤트, 한 달동안 미 접속시 새로운 대회 알림 보내는거 이거를 위해서 사용자 로그인 로그를 기록할 수 있는 log table 만들어서 데이터 저장                 
- 대회 상태 수정           


#### 이슈 

<pre>
let upload = multer({
    storage : multerS3({
        s3: s3,
        contentType: multerS3.AUTO_CONTENT_TYPE,
        bucket: "aniple/advertisement",
        key: function(req, file, cb) {
            console.log(file);
            //이미지 이름 바꾸기
            let fullpath = file.originalname;
            cb(null, fullpath);
        },
        acl: 'public-read-write',

    })
})
</pre>

contentType을 multerS3.AUTO_CONTENT_TYPE 이렇게 설정하면 클라이언트에서 오는 파일 타입을 해당 파일에 맞게 content-type을 자동으로 설정해서 넣어준다.         
      
여기서 contentType 을 auto 로 지정해서 content type을 일치시켜야한다. AWS 이미지를 다운로드를 하지 않고 링크로 보일 수 있도록 하려면 content type을 일치시켜야 한다.                
==> 문의 하신 내용 중, 이미지 파일이 다운로드되는 경우와 화면에 그대로 보이는 경우의 차이는 S3 metadata의 "Content-Type"이 다르기 때문일 수 있습니다. 아래 링크 참고하시어 테스트 부탁드립니다.          
이를 해결하기 위해서 꼭 필요하다.          

이미지 이름 original name 말고 다르게 변경해야한다.           
안그러면 중복이 돼서 이미지가 덮어진다.               

#### 진행 방법
##### 로그인 접속 기록 등 log 관련 처리 방법 
로그인 중일 때도 접속했는지 안했는지 알아야하기 때문에 앱 버전과 os를 클라이언트한테 받는 api 를 만들어야한다. 앱 버전이랑 os를 클라이언트한테 받고 그 접속 기록을 남기는 log_user에 데이터를 저장을 해야한다.         
푸쉬알림을 전송하기 위해서 사용자가 앱 접속 기록을 남기는 db table을 만들고 기록에 필요한 API        
1. 로그인 안한 상태일 때, 로그인 하면서 사용자 로그 기록을 남긴다.          
2. 로그인 한 상태로 앱을 새로 접속한 경우 클라이언트에게 os, 앱 버전 정보를 받는 api를 새로 작성한다.            
==> 해당 API 구현 시 상세 설명 기재 필수 !!            
> 로그 기록하는 테이블에서 push token은 굳이 안 넣어도 user table에서 알 수 있기 때문에             

swagger나 api에서 로그를 기록 하는 api를 따로 분리시켜서 개발해도 좋을 것 같다.               

##### 푸시 알람 처리 방법
<푸시 알람 정보>     
![image](https://user-images.githubusercontent.com/52439497/95009537-ce6e6a80-065d-11eb-8760-e54b0ed49fd1.png)

Push 알람을 전송하기 위해 반복적으로 알람을 보내는 함수를 실행할 수 있는 node schedule을 설치해서 진행하였다.               
이벤트 발생은 푸시 알람을 전송을 하면 바로 보내면 되지만 한달 동안 접속 안한 사람들에게 푸쉬 알림 보내는 것은 자동으로 푸쉬 알람을 보낼 수 있도록 진행하는 것이 좋다.    

###### 그러기 위해서 node schedule or cron이 필요하다.           

![image](https://user-images.githubusercontent.com/52439497/95009656-af240d00-065e-11eb-9ec5-b8642241737c.png)

출처: https://yonghyunlee.gitlab.io/node/node-schedule/     

근데 scheduler를 실행하는 시점이 언제이어야 할지.. api 호출할 때마다 할 필요는 없고       
그냥 실행할 때 bin/~ 여기를 실행하니까 doitpower 부분에 스케줄러 함수를 넣어서 진행하는 것이 나은가,,?          
그리고 push 알람 관련한 function 들은 따로 정리해서 분리시키자.          

##### node schedule 사용해서 이벤트 처리하는 경우 
###### 기간 계산을 할 때 이용
Datetimediff의 경우는 일 차이만 구할 수 있다.        
근데 timestampdiff -> month, second, minute 이런 식으로 원하는 단위를 지정해서 시간 차이를 구할 수 있다.     

<pre>
timestampdiff(month, user_log.created_time, now())
</pre>
-> 최신 유저 로그랑 현재 시간이랑 달 차이를 계산해서 달이 1 이상이면 한달이상 차이가 난 것         



### 200916
- 대회 종료하고 나서 푸쉬 알람 전송하는거
> 대회 종료한 것은 매일매일 확인하니까 대회 종료일이랑 현재 날짜랑 같은 애들만 푸쉬 알람을 전송하게 하면 될 것 같다. 자정에 대회가 종료되면 그 날 새벽 1시 이런 식으로 푸쉬 알람을 보내면되지 않을까..?       
- 관리자 페이지는 프로젝트를 따로 뺄 것이어서 일단 api랑 proc만 구상하기        
- Push 알람 스케줄 함수를 언제 어디서 실행하는 것이 좋은가,,, 실행했을 때 한번 실행하게 냅두는건가,,?          
- 한 달동안 접속 안한 사용자 푸쉬 알람 전송하는거        
- 관리자 페이지 API 생각해보기      
> 관리자 페이지는 proc도 앱  proc이랑 다르게 네이밍을 해야한다.        
- swagger랑 다 반영한거 서버에 올리기        
- swagger에 log 부분 아예 상단에 설명을 적고, api path도 하고 그 api를 테스트할 수 있는 링크를 작성하는 것이 좋다.         
- Fcm 실행하는 부분은  cron이라는 폴더를 따로 빼서 실행을 app.js 에서 실행을 할 수 있도록 한다(서버가 한번 실행될 때 그 때만 실행하면 되기 때문에)       

#### 배운 점 
##### 여러명에게 동시에 push 알람
주제가 아니라 token을 이용해서 여러명에게 한번에 푸시알람을 전송하려고 하는 경우,        
![image](https://user-images.githubusercontent.com/52439497/95009724-38d3da80-065f-11eb-8f91-3e19586911ff.png)
> 대신 한번에 전송할 수 있는 토큰 수는 최대 1000개     

#### 관리자 페이지 API 구성
1. 대회 생성, 수정, 삭제 API(대회 최소 인원, 인증 유형이 대회 정보 수정하는 것에 포함)      
2. 광고 생성, 수정, 삭제 api          
3. 우승예상상금을 계산할 때 필요한 10 ~ 30% 상금 비율 수정하는 api(대회 수정할 때 필요한건가) + 휘트니스 혜택 비율         
4. 인증 정보 이의 제기 목록 확인, 이의 제기 처리할 수 있는 화면, api 작성(이의 제기하면 현재 점수에 반영 x => certify value 계산할 때 처리)         
5. 포인트 환급 요청, 우승 예상 상금에 대해서 유저에게 보내는 일을 해야 포인트(적립에 대해서는 어떻게 처리를 해야하는 것인가) 환급 요청에 대해서 처리를 할 수 있도록          
6. 이벤트 푸시 알람 보낼 수 있도록 화면, api        
7. 사용자 관리? 회원정보를 관리한다면 어떤 것을 할 수 있는지?           
8. 이벤트 생성, 수정, 삭제 API          
-> 관리자 페이지 procedure 만들 때, admin에서 사용하는지 아닌지를 procedure 이름으로 구분지어도 괜찮은건가?       
##### 관리자 procedure 랑 일반 app procedure랑 구분지어서 짓는 것이 좋다. 

#### 관리자 페이지 리스트 pagination
https://velog.io/@minsangk/%EC%BB%A4%EC%84%9C-%EA%B8%B0%EB%B0%98-%ED%8E%98%EC%9D%B4%EC%A7%80%EB%84%A4%EC%9D%B4%EC%85%98-Cursor-based-Pagination-%EA%B5%AC%ED%98%84%ED%95%98%EA%B8%B0

커서 기반 페이지네이션을 위해서는 반드시 정렬 기준이 되는 필드 중 (적어도 하나는) 고유값이어야 합니다.           
-> 정렬 기준이 되는 필드는 적어도 tuple사이에서 unique해야한다.           

![image](https://user-images.githubusercontent.com/52439497/95009765-79cbef00-065f-11eb-931f-83691cf840f3.png)


Order by 를 사용하면 전체를 스캔하기 때문에 성능이 저하되는 이슈가 발생할 수 있다. 하지만 limit을 사용하면 전체를 스캔하지 않고 일부만 스캔할 수 있기 때문에 성능 저하 이슈를 해결할 수있다.       
관리자 페이지에서 관리자 인증을 하는 middleware를 만들어야 한다.        
—-> 관리자 api 는 또 다른 프로젝트를 생성해서 진행한다.         


### 200917
#### 의문점
- 관리자가 이의제기처리할 때 관리자가 문제가 있다고 파악해서 인증정보를 삭제한 경우 해당 인증정보를 삭제한 사실을 사용자에게 알려야하나?       
> 인증 정보 삭제한 사실을 굳이 알릴 필요 없다.      

- 포인트 관련해서 포인트 충전한 경우 금액 확인하고 금액에 맞게 충전하는데 금액을 확인하는 것까지 할 필요 없겠지?        
> 없다.          

- 포인트 적립의 경우 대회가 종료한 다음에 우승 상금을 주는건데 시스템에서 바로 주는 식으로 해야하나 아니면 관리자 페이지에서 보여주고 관리자한테 확인을 받아야하나?       
> 적립은 바로 이루어지면 된다. 우승 상금 적립이 아닌 이벤트성 적립은 따로 생성할 수 있도록 해야한다.        

- 대회 참가할 때 결제 취소는? 어떻게 처리를 해야하지?       
> 자세한 확답은 없으신데 일단은 결제 취소되면 포인트 사용내역 삭제처리하도록 한다.          

- 결제 요청 들어오면 포인트 목록을 생성하는 api를 실행하면 되는데, 사용자가 포인트 충전을 하는 경우 그러면 포인트 충전 결제 요청을 알려주는 상태가 필요하지 않을까?      
- 결제 요청 log 를 생성해야하나?        
> 포인트 충전, 사용 이런거를 내역을 남기면 된다. 대신 이 내역은 포인트 테이블에 목록으로 생성된다.         

#### 진행 방법
##### 우승 예상 상금
- 내 생각엔 상위 10%, 상위 20%, 상위 30% 각각 우승 상금 비율이 정해져있어서 대회 필드에 따로 추가를 해야할 것 같다. (맞다. 대신 default 값 필요)            

##### 미래에 할 일 
- 대회가 종료되면 30%안에 드는 상금 수령자들에게 각 상금에 대해 포인트를 충전하고, 포인트 적립 목록을 생성해야한다.         
> 먼저 랭킹 계산하고 우승 예상 상금 계산(function으로) 한 다음에 user table 업데이트하고 point table insert             
- 관리자 페이지 API 구상       
- 관리자 페이지 구성        
- 우승 예상 상금 프로시저 구현         


### 200918 관리자 페이지 procedure 만들기(대회, 사용자 목록 ,포인트 목록)
- 포인트 목록      
- 이벤트 상세 정보      
- 인증 정보 삭제      
- 이벤트 목록        
- 이의 제기 시 처리하는 procedure       
- 사용자 해당 대회의 인증 정보 목록 가져오기 -> pagination?         
- 관리자 로그인 procedure(관리자 테이블 따로 생성)      
- 이의 제기 목록              
- 사용자 포인트 내역 생성 procedure       
- 사용자 포인트 목록 procedure       
- 사용자 목록 procedure         
- 대회 참여한 사람 목록 procedure       
- 대회 수정 procedure        
- 대회 삭제 procedure         
- 대회 생성 procedure       

#### 의문점 
- 관리자 정보를 관리할 필요 없겠지? 관리자 정보 목록 가져오고 그럴 필요 없을 것 같다. 회원정보를 굳이 가져올 필요 없으므로            
- 포인트 충전의 경우, 충전은 충전 요청, 충전 완료 이렇게 상태가 분리된 것이 아니라서 관리자가 충전완료를 했을 때 어떻게 반영해야하는지 애매하다.           
- 한달 동안 미접속한 사용자에게 새로운 대회 알람을 보내는데 이 경우는 그냥 제일 최근에 새로 생긴 대회 정보를 보내면 되는건가 어떤 형태로 보내지          


### 200921
#### 의문점 
- 관리자가 충전완료를 한 경우 상태가 어떻게 변하는지 궁금하다.     
> 충전은 포인트 충전상태만 존재하기 때문에(무통장입금의 경우 충전 완료 여부를 관리자에서 알려줘야한다)      
- 사용자 user table에 last connection은 어떤건지?       
- 주 몇 회 인증이 존재하는데 관리할 필요가 있나? 인증 못한거에 대해서 제재를 가해야하나?      
> 한다면 주를 어떻게 계산하지 대회 시작일 기준으로 주를 세면 되는건가???          
- 대회 리스트에서 보여주는 예상 상금은 어떻게 계산해서 보여주는것인가         


##### -> 우승상금계산을 할 때 대회 정보를 가져오고 상금수령자 참여금 총합을 구하는 부분이 있는데, 이 부분을 procedure로 그냥 다 넣어서 할지(그러면 멤버마다 우승 예상 상금 구할 때 계속 중복 계산이 이루어짐) 아니면 따로 빼서 진행하도록 한다. 
- 내가 참여한 대회 리스트에서 종료 상태라면 내 우승상금을 보여줘야한다.           
- 사용자 정보에 사용자 포인트랑 레벨을 같이 보여주는 것이 좋나 ?  일단은 그렇게 한다.      
- 대회 종료 되면 사용자한테 적립금 나눠주는 쿼리 -> push 알람 보내면서 같이하면 될 것 같다. (근데 query가 약간 구리다)        
 
> 포인트 적립하는 query 해야한다.               
> 종료된 대회 리스트를 가져오는 query를 먼저 실행하고, 실행한 후에 각 대회마다 우승자들 가져오는 query를 진행한다. 
> Query 진행 후 우승자들 가져올때 랭킹도 함께 같이 가져오기 때문에 우승자마다 상금을 가져오는 query를 진행하고 query 진행 후 우승자 참여금에 따라서 우승 상금 계산하고 계산한 다음에 우승자 랭킹에 맞게 우승 상금을 정한다. 그리고 해당 우승 상금을 적립하는 query를 진행하면 된다.              
> 이 때 종료된 대회 리스트를 가져오기 위해서 사용자 push token을 가져오는데 join하면 대회가 중복으로 가져와서 중복을 없애기 위해 push token이랑 uid를 group_concat을 이용해서 한번에 가져올 수 있도록 하였다.        

<pre>
SELECT CONCAT("[", GROUP_CONCAT(category.name), "]") AS categories
From categories
</pre>

이렇게 가져오면 array로 사용하거나     

<pre>
group_concat(distinct _user.push_token separator ',') 
</pre>

이렇게해서 받아온 다음에 split(‘,’) 해서 배열로 저장하면 된다.       

### 200922

- 주 마다 몇회 인증했는지 처리           
- Cron 이용해서 자정마다 대회 상태 확인하고 포인트 반환이나 팀 상태 update 하는 방법을 사용하는 것이 어떤가…!!! 
- 대회 상태 계산하는거 다시 구현해야한다. 왜냐하면 대회의 특정 팀만 계산하기 때문이다. 
> 대회 상태(신청중, 진행중, 종료) 이거 구하는 query 하나랑 대회 취소 상태를 계산하는 query를 계산을 해야한다. 인원 미달인 경우에는 처리할 수 있지만 팀원 미달인 경우는 따로 처리를 해야한다.  대회 상태 정리
- 팀원 미달인 경우는 참여 현황이나 우승자 계산, 우승 상금 계산, my list에서 제외시켜야한다. 
> 팀원 미달인 경우 팀을 삭제하면 안된다. 우승 상금 계산하고 그럴 때 제외시켜서 진행해야한다. 
- 우승 예상 상금 참여하기 전 모든 참여자가 5만 포인트로 참여했을 때를 기준으로 계산한다. 
- 관리자가 포인트 충전 상태를 관리할 수 있도록 충전 요청/ 충전 완료 상태로 나눠서 처리한다. 
- 프로필 사진 수정하면 기존 사진은 삭제하고 추가할 수 있도록 한다.        
> 내 생각에는 사용자 프로필 사진인 경우 생성할 때 기존 사용자 프로필이 존재한다면 삭제하고 새로 생성할 수 있도록 하는 것이 나을 것 같다.          
- 사용자 레벨 필드 따로 만들어서 우승자들 계산할 때나 아님 서버에서 query를 이용해서 update 하도록 한다. 적립될 때마다(우승할 때마다) 레벨이 하나씩 증가하기 때문에          

#### 이슈
- 사용자가 대회 my list를 확인하는 경우 그 때마다 대회 상태를 계산하는데 이런 경우 대회가 인원 미달이거나 팀원 미달인 경우에 대해서 처리해주기가 애매하다. 그리고 한번 확인하고나서 계속 진행하면 중복해서 처리하는 query를 진행하여 성능도 떨어질 것 이다.          
##### => 그래서 node_schedule을 사용해서 매 자정마다 대회 상태를 확인하고 이에 대해서 처리해주는 역할을 하는 것은 어떤가? 그러면 중복해서 진행할 필요도 없고 하루에 한번씩 확인하고 진행하면 되기 때문에 훨씬 더 효율적일 것이다.        


### 200923
- 팀 상태가 -1 인 경우 제외시키기 (우승 예상 상금, 우승자,  join count 등)
> join count 셀 때 대회 진행 전이면 -1이 될 수 없으니까 그냥 -1 제외해서 세면 될 것 같다.         
> 그리고 인원 미달인 경우 팀일 때 팀 상태 -1 인거 제외하자             
> 대회 총 상금 계산할 때 team 상태 -1인거 제외하기       
> 대회 참여 인원 구할 때 single인 경우는 status가 2니까 신경 x 그냥 팀전인경우       
> 상금 수령자 총 참여금 계산하는 경우 team 전인경우 status -1인 경우 제외     
> 팀 중복 확인할 때 물론 필요 없겠지만 혹시나해서 status -1 인거 제외한다.          
> 인증 정보 목록 가져올 때 team status -1 인 경우는 상관없다. 왜냐하면 status -1이면 참여할 수 없기 때문       
> 대회 종료의 경우에도 팀 상태가 -1 이  아닌 애들한테 보내도록       
> 리더 포인트 가져올 때 팀 상태가 -1 이 아닌 경우       
> 랭킹 계산하는 경우 team status -1이 아닌 경우 만       
> 팀 정보 가져오는 경우도 status -1인경우 제외         
> 우승자 리스트 가져오는 경우도 status -1인 경우 제외         
> Team certify value 계산할 때도 team status -1인 경우 제외                

- 대회 참여 취소한 경우 인증 정보도 삭제가 되는 것인지 -> 삭제한다. 그러면 내 인증 목록에서 안보여줘도 되는 것인가?          
- Client 에러를 확인한 결과 한 대회에 중복 참여해서 그런거같은데 중복 참여를 서버에서도 막아야하는지 -> 막아야한다.        
- func_select_contest_user_prize_point y이거 아무것도 없는데 어떤 역할을 하는 것인지          
- 관리자 procedure에서도 team status 조건 걸어야 하는거 생각해보기          
> 근데 관리자 페이지에서는 굳이 team status 를 나눌 필요가 없을 것 같다. 왜냐하면 다 보여줘야하기때문에              
- 대회 참여할 때 팀 상태 update 안된다.          
- 프로필 사진이 아니더라도 인증 사진 이런거 사용자가 수정할 수 있나?         
> 사용자는 자기 자신 프로필 사진만 수정할 수 있다. 대회 인증 사진은 어디서도 수정 불가 그리고 광고나 이벤트 같은 경우는 관리자에서 수정할 수 있다.         
> 프로필 사진 수정하면 기존 사진은 삭제하고 추가할 수 있도록 한다.       
> 내 생각에는 사용자 프로필 사진인 경우 생성할 때 기존 사용자 프로필이 존재한다면 삭제하고 새로 생성할 수 있도록 하는 것이 나을 것 같다.         


### 200924
1. 대회 취소된 경우 포인트 사용 내역 처리하는 방법이 애매 (o)         
2. 그냥 포인트를 적립 + 충전완료 - 사용 - 환급 완료로 해야하나 근데 이러다가 환급 예정인 포인트 포함 안해서 돈 꼬이면? (o)        
3. Cron(node_schedule) 이용해서 자정마다 대회 상태 확인하고 인원 미달인 경우, 팀원 미달인 경우에 대해서 포인트 반환이나 팀 상태 update 등 처리하는 방법을 사용하는 것은 어떤가?            
> proc_update_contest_team_status 를 이용해야한다.(o)                
4. 주 마다 인증 횟수 충족 못한 경우 어떻게 처리를 해야하는지 (세모)          
5. 대회 취소한 경우에 대해서도 -> 관리자 —> 사용자 포인트 반환될 수 있도록 근데 대회가 중간에 취소되는 경우가 있나? (x) 
> 만약 있다면 취소된 경우 대회 참여한 사용자들 삭제하도록 해야하나? 팀이랑 그리고 인증 정보도 삭제해야한다.         
> 즉, 멤버랑 팀을 취소된 경우에도 삭제를 해야하나 아니면 그냥 냅두는 것인가.           

- Cron 사용해서 자정이 될 때마다 팀 상태를 변화시키고 -1 로 변화하고 그리고 인원 미달이거나 팀원 미달인 애들은 대회 참여 못하니까 그거에 대해서 대회 참여를 위해 포인트 참여금을 삭제하도록 하는 query를 사용한다. 
- 인원 미달인 경우 ok
- 팀원 미달인 경우 ok 
- 잔여 포인트를 계산할 때 적립 + 충전 - 사용 - 환급 완료 로 보여주고 포인트 사용할 때는 환급 예정인 포인트를 제외해서 사용할 수 있는 포인트를 제외해서 사용할 수 있도록 한다. 그래서 function을 2개 만들어서 계산해야할 것 같다. 
- 대회 취소한 경우 그 때 contest team, member를 삭제해야하나 ..? 일단은 포인트만 삭제하도록 한다. (관리자)
- 주 마다 인증 횟수 충족 못하면 실패 처리를 해야하는데 그러면 이 상태를 저장할 곳이 없다.
- 그리고 대회 참여금인 것을 알려주기 위해 point tbl 에 contest_uid 추가 -> 대회 참여금 사용이 아닌 경우 -1로 설정되도록 한다. (대회 참여하는 경우 대회 uid 추가하도록 한다.)     
- Env 파일에서 db 변경하기 -> my real test 이렇게 3개로 나뉜다.        
> 팀전에서 한명이 주마다 인증 횟수 충족 못한 경우 그 팀 전체가 실패하면 team table에 status를 추가하면 되는데 그런 것이 아닌 경우는 member에 status 필드를 추가해서 진행을 해야할 것 같다.          

## 이슈 
개인 개발 서버에서 개발을 하면 디비랑 같이 바로 바로 테스트 개발 서버에 맞춰야한다.        
근데 어떤 기준으로 올려야할지 모르지만 일단 프로시저 이름이 바뀌거나 프로시저가 추가된 경우에 테스트 개발 서버에 올린다.       


### 200925

- 포인트 계산 (잔여 포인트랑 실제 사용할 수 있는 포인트랑 나눠서 계산하는거)
- 잔여 포인트 보여주는건 사용자가 포인트 목록 확인하거나 그럴 때 사용한다. func_select_remaining
- 실제 사용할 수 있는 포인트는 대회 참여할 때 사용한다. func_select_available_point
- 버그 수정
> 이벤트 목록을 주지 않는다.          
> —> 1. 메인 홈페이지에서 보여주는 이벤트 목록(진행중인 이벤트) -> API 만들기 아니다         
> —> 2. 이벤트 목록에서 보여주는 이벤트 목록은 지난 이벤트도 전부 보여주면 된다.           
> —> 3. 사이즈 맞게 적당한 이미지 올리기 (완료)          
> —> 4. 진행중인 이벤트 보여줄 때 최대 갯수 정하기 한 6개..? 날짜 기준 6개로 하면 될 것 같다.            
> —> 이벤트 목록은 진행 여부를 확인하지 않는다. 메인에 나오는거랑 목록이랑 같은 이벤트일 것 같다.         
- 피트니스 정보 수정하기 api 호출시 서버에러 (수정)          
- 로그아웃 api 호출시 서버에러 (로그아웃은 post 로 진행한다.)            
- 관리자 procedure 에서 팝업광고 리스트랑 아닌거랑 다르게 보여주도록 그냥 pop_show 로 구분해서 보여지도록 함       
- 관리자에서 대회 취소한 경우 포인트 삭제하는 작업     

#### 의문점
1. 주 마다 인증 횟수 충족 못한 경우 어떻게 처리를 해야하는지         
-> 팀전에서 한명이 주마다 인증 횟수 충족 못한 경우 그 팀 전체가 실패하면 team table에 status를 추가하면 되는데 그런 것이 아닌 경우는? member에 status 필드를 추가해서 진행을 해야할 것 같다.              
==> 그러면 주 마다 인증횟수를 충족 못한 경우 팀 전체가 실패하는 것으로 해서 상태를 추가해서 진행한다.        

##### 1번 의문점 해결법 
- tbl_contest_team status 서버 db 추가         
- Status -2로 업데이트하는거 수정해야한다.       
- 그리고 cron써서 매일 낮에 확인하여 status 업데이트 하도록 한다.          


### 200928
- 주 마다 인증 횟수 충족 못한 경우 처리(실패한 경우이므로 포인트를 반환할 이유가 없다)            
> Cron 써서 매일 진행할 수 있도록 한다.                       
- Ranking 계산할 때 실패한 팀(status -2인 경우)은 상위 100%로 설정하고 제일 낮은 등급으로 둔다…?      
> 일단 그냥 계속 랭킹 계산할 수 있도록 한다. 그럼 그냥 -1 인 상태만 제외하도록 한다.        
> 이거는 매일매일 확인해서 진행할까? 그러면 너무 비효율적이니까 오늘 날짜의 하루 전 요일인 contest 가져와서 해당 contest 반복해서 team status 업데이트 하도록 한다. (왜냐하면 자정에 확인하는 게 좋으니까! 낮에 확인해서 인증했는데 인증 처리 안된걸로 진행되면 안되니까!)         
- 팀원 중 한명이라도 실패한 경우 팀 전체 실패 상태로 update       
- 디비, api 업데이트       
- 대회 참가할 때 시작 날짜 이후인 경우 참여 못하도록 막는다(완료)         
- 개인전 참가했는데 왜 status가 1인가 -> 잘못 설정된 듯 일단 킵       
- 관리자 페이지 api 정리         

#### 의문점
1.  Image의 seq는 순서가 낮을수록 먼저 보인다는데 이걸 어떻게 설정하나요?       
##### 답 
-> 이미지가 여러개일때 순서용 필드로 쓰려고한건데 지금은 1장 이상 사용하는게 없어서 지금은 의미 없을거같아요       

2. 대회 취소한 경우에 대해서도 -> 관리자 —> 사용자 포인트 반환될 수 있도록 근데 대회가 중간에 취소되는 경우가 있나…?        
만약 있다면 취소된 경우 대회 참여한 사용자들 삭제하도록 해야하나? 팀이랑 그리고 인증 정보도 삭제해야한다.        
-> 즉, 멤버랑 팀을 취소된 경우에도 삭제를 해야하나 아니면 그냥 냅두는 것인가.             
-> 중간에 대회를 취소하는 경우는 없어야할 것 같다.       
##### 답 
대회는 진행중일때 취소하는 경우는 있으면 안될거같다. 취소시 그에 대한 이슈 해결은 관리자가 처리하는게 맞을듯하다.             
반환 여부는 관리자에서 공지나 별도 이메일등으로 알리는게 맞을거같다.              


1. 대회 참여 취소한 경우 인증 정보도 삭제가 되는 것인지 -> 도중에 취소할 수 없으므로 인증정보가 삭제되지는 않을 것 같다.        
2. 대회에 실패한 경우 ranking 계산은 어떻게 처리하는 것인가 ? 그냥 그대로 계산          
3. 대회 진행 전에 관리자가 취소한 경우 대회 정보 삭제하고 나서 멤버들 포인트 반환하도록       

#### 주의
- 버그 1번처럼 데이터 충돌로 생긴 오류를 해결한다면 데이터를 그냥 내가 임의로 하나 지워도 된다. 

#### 배운점
- Mysql now()는 timestamp type이어서 시간, 분, 초를 비교한다.           
- curdate() 또는 current_date 는 시간, 분, 초와 상관없이 yyyy-mm-dd로 나와서 시간, 분, 초를 고려하지 않는다.        
- Mysql date_sub()은 날짜 빼기 date_sub(기준 날짜, interval 1 day) 하면 기준날짜 하루 전을 가져온다.         
- Mysql dayofweek(date)하면 해당 date의 요일이 출력된다. 일요일이면 1, 월요일이면 2, 화요일이면 3 이런 식으로          
- 오늘을 기준으로 대회의 시작 주 ? 날짜를 구하는 query           
<pre>
select @week_diff := timestampdiff(week, start_date, now())  as week_diff
     , date_sub(start_date, interval (@week_diff * -1) week) as week_start_date
from tbl_contest
where uid = 3
  and is_deleted = 0
</pre> 

먼저 오늘 날짜랑 시작 날짜랑 주간 차이를 구하고 대회 시작 날짜에 주간 차이만큼 주를 더해서 오늘을 기준으로 인증 주간의 첫 날짜를 구한다.          
Update tbl set col  = default(col)하면 default 값으로 업데이트 된다.                 
and (isnull(in_objection_status) or _objection.status = in_objection_status) 이런 식으로  where 절에 조건을 달면 in_objection_status 가 null인 경우 또는 inobjection_status가 정해져 있는 경우 이렇게 해서 데이터를 가져올 수 있다.          


## GIT 을 이용하여 데이터베잇 버전 관리! VCS 


### Database git version 관리하는거
- 일단 repository 만들어서 git init하고 test로 dump 해놓은거 올려놨다.      
- branch 하나 만들어서 procedure 수정했는데 이렇게 procedure 하나에 대해서 수정됐는지 아닌지 git으로는 알기 힘든거 같다…ㅠㅠ      
- 그래서 일단 수정하고 나서 해당 git 폴더에 dump 하니까 그래도 데이터가 변경되었다고 뜨긴 하는데,,, 파일 전체가 다 수정됐다고 뜨니까 뭐가 어떻게 바뀌었는지 확인하기 힘들다.       
 
#### 일단 다시 repository 연결해서 하긴 했는데 routines 경우에도 diff를 통해서 어디가 어떻게 달라졌는지 확인할 수 있다.             
#### 근데 그래도 db 수정하고 dump해서 git commit 하고 diff 확인하는 수밖에 없을 것 같다.      

#### 데이터 추가하고나서 데이터 추가한 테이블만 dump해서 git commit 하고나서 diff 를 이용해서 어디 부분이 달라졌는지 확인할 수 있다. 어떤 데이터가 추가되었는지. 

#### 전체를 dump한 경우는? 어떤걸 수정한지 몰라서 
이런 경우는 전체 다 modified 상태가 되지만 diff 확인해보면 차이가 없다는 것을 알 수 있다. 전체를 다 올려도 diff를 이용해서 차이점을 확인할 수 있다.          
각각 파일마다 확인할 수 있다. 원래와 어떤 것이 다른건지      
 
