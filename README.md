# My Internship Record 

### 200706 express & swagger & mysql
> mysql foreign key, primary key 이용해서 관계 생성           
> erd 확인            

### 200707 project DB 생성
> aniple project 화면을 보고 필요한 데이터베이스 테이블 생성          
> err 을 통해 데이터 베이스 구성                  
<pre> Error: ER_NOT_SUPPORTED_AUTH_MODE: Client does not support authentication protocol requested by server; consider upgrading MySQL client        </pre>  
> 이런 에러가 발생!!! 권한 문제인 것으로 판명

### 200708 DB 수정 & API 설계
> aniple DB를 수정함. 병원, 약국, 용품, 미용이 서로 같은 내용이기 때문에 db 를 합치고 type column을 추가해서 구분할 수 있도록 한다.             
> 그리고 DB의 character type은 utf8이 아닌 utf8mb4!              
> 왜냐하면 utf8은 특수문자를 하나도 인식을 못한다. 그에 비해 utf8mb4는 특수문자를 인식하기 때문에 더 좋다.       
> DB 테이블에 create time, update time, delete 여부, uid를 모두 default로 넣는 것이 좋다.       
> 사용을 하지 않아도 통일하는게 가독성을 높일 수 있다.(애매)             
> 또한 primary key인 uid를 auto increment로 하면 성능을 높일 수 있다.         
> 조회수 테이블, 이미지 테이블은 따로 만드는 게 좋다.         
> 조회수의 경우, 의뢰하는 곳마다 다르게 count할 수 있기 때문에, 그리고 이미지 같은 경우 이미지가 하나라면 상관이 없지만 여러개인 경우 테이블을 따로 만드는 것이 좋다.             


> api를 설계를 하고 swagger를 이용해서 명세서도 작성하고 api 구현도 하였다.      
> 근데 이벤트 글 pagination을 어떻게 해야할지 좀 더 고민을 해봐야할 것 같다.

### 200709 DB 수정 & API 수정
> API는 적을수록 좋다. 병원, 약국, 애견용품점, 애견 미용샵을 합쳐서 하나의 DB로 구성했는데, client에서 쉽게 구분할 수 있도록 store를 병원, 약국 ~ 이렇게 나눠서 API 설계함.           
> 근데 이는 좋은 방법이 아니다. API는 적을수록 좋은 것이다.         
> 그래서 나눈 API를 다시 합치고, swagger도 수정했다.              
> 또한 DB에 query를 이용하여 위,경도 거리 계산을 진행하여야 했다.          
> 하지만 먹히지 않았는데, 수정을 하였다.            
> 또한 긴 query문은 procedure나 function을 이용하는 것이 좋다.          
> procedure은 실행, 절차 이런 느낌인 반면 function은 계산을 할 때 이용을 한다.           
> 거리 계산은 어찌보면 function인 것 같긴 한데 거리를 구해서 select해서 store를 가져오니까 procedure도 상관없지 않을까라는 생각을 한다.               
> function은 또한 꼭 return 값이 존재해야한다!!!!! 
> aniple은 사용자를 가지고 있지 않지만, user table을 만들고 사용자만의 token을 가질 수 있도록 구현을 해봤다.         
> 로그인을 하면 jwt token을 발급해서 이를 저장하고 이 token을 가져야만 api를 사용할 수 있도록 구현을 했다.               

### 200710 User db 수정 & 가독성을 위해 api 파일마다 분리 & query를 모두 procedure로 & 예외처리
> 앱의 경우 사용자가 설치를 하면 고유번호가 주어지는데 이를 이용해서 사용자를 구분할 수 있다.         
> 따라서 이 고유번호를 이용해서 token을 만들어서 사용자를 구분할 수 있도록 구현하였다.         
> 고유번호와 token을 추가해야하기 때문에 DB를 수정하였다.            
> 나중에 확인했을 때 뭐가 뭔지 잘 파악할 수 있도록 접근하는 db 테이블 마다 폴더를 나눠서 api를 하나씩 분리하여 파일을 만들었다.        
> 파일을 만들어서 그 안에 swagger 명세서와 api를 모두 작성하였다.         
> 또한 query를 어떤 것은 query, 어떤 것은 procedure 이렇게 하지말고 모두 동일하게 procedure로 바꿨다.      
> select 명령어 하나이더라도 procedure로 하여 통일했다.       
> api 설계 시 파라미터나 frontend에서 전달되어야하는 데이터가 전달되지 않은 경우에 대해서 예외처리를 해주었다.      
> 403으로 예외를 알려주고 어떤 에러인지 알 수 있도록 swagger를 통해 명시하였다.          

### 200713  pagination 구현
> pagination은 limit, offset을 이용해서 하는 방법과 cursor based 방법이 있다.       
> limit, offset을 이용해서 하면 다음 페이지를 넘어갔을 때, 이전 페이지에 있던 데이터가 중복해서 나오는 경우가 종종 존재한다.        
> 그리고 실시간으로 글이 삭제되거나 추가된 경우를 대처할 수 없다는 단점이 존재한다.          
> 하지만 cursor based pagination은 client에게 알려준 이전 페이지의 마지막 게시글의 id를 알고 이 id 이후의 데이터를 가져오면         
> 데이터가 추가 및 삭제가 되어도 중복이 되지않고 데이터를 보여줄 수 있다.       
> 따라서 cursor based pagination으로 진행하였다.      

### 200714 pagination 기능 보완 & function으로 나누기
> 전날 구현한 cursor based pagination을 보완하였다. 왜냐하면 pagination을 할 때, 마지막 페이지인 것을 알려주면 client에서 더 이상 query 요청을 하지 않아도 되기 때문에      
> 효율적이다. 이를 위해서 전체 페이지 수, 남아있는 페이지 수, 현재 페이지를 알려주는 query를 구현하였다. 
> 이 query는 api를 따로 날려서 진행하는 것이 아니라 이전에 list를 요청하는 query 안에서 내부적으로 진행할 수 있도록 구현을 하였다. 
> 또한 api 코드에서 parameter를 검증하는 function은 나중에 사이즈가 커지면 한 function 안에서 다루기 힘들어서 parameter를 검증하는 function을 만들어 분리하였다.           
> mysql query 같은 경우에도 한 function안에 두지 않고 querySelect, queryUpdate 라는 이름으로 function을 만들어 분리하였다.        
> 분리한 후에 각각 error에 대해 처리를 할 수 있도록 Promise를 만들어 return 하고 async, await을 이용하였다.         
> 처음에는 async, await, promise를 사용하지 않아서 db에서 결과가 제대로 가져오지 않았다.      
> async, await, promise를 이용해서 해결을 할 수 있었고, try catch를 이용해 에러를 쉽게 처리할 수 있었다. 
> 그리고 api에서 path parameter는 아무리 숫자를 입력해도 string으로 인식이 된다. 주의하자!             
> db에서 가져온 결과가 아무것도 없는 경우에도 검증하는 함수를 따로 분리하여 검증하였다.    

### 200715 rds mysql 이용 & query 함수 더 나누기
> query나 parameter를 check하는 함수들은 api에서 공통적으로 사용이 될 수 있기 때문에 util이라는 폴더를 만들어서 그 안에 paramUtil, queryUtil 파일을 생성하였다.       
> 이 각 util 파일에 parameter를 method에 맞게 가져오거나 있는지 없는지 check 하는 함수를 만들어서 util 파일 require만 해서 가져올 수 있도록 코드 구조를 변경하였다.     
> query util의 경우 select해서 array로 오는 것과 객체 하나로 오는 것을 나눠서 함수를 작성하고, query에 필요한 parameter에 따라서 query 함수를 구성하였다.      
> 이렇게 함으로써 더 간결하고 나중에 스케일이 커지는 경우, 기능 추가 및 보완을 더 용이하게 할 수 있다.         
> 또한 로컬에서 사용한 데이터 베이스를 rds 에 올리기 위해 character set을 맞추었다.        
> utf8이 유명하지만 이모티콘이 적용이 되지 않는다. 그래서 utf8mb4, utfmb4_general_ci를 이용한다.      

### 200716 router 함수들 분리 & 조회수 업데이트 query 작성
> 전 날에 util 폴더를 만들어서 query랑 parameter를 check 하는 함수를 나누어서 작성하였는데, 이를 사용하는 부분도 router.get function안에서 한번에 이루어지도록 하는 것이 아니라     
> 이를 사용하는 것도 다른 함수로 나누어서 역할을 명확하게 하였다.      
> router.get 이런 식으로 처리하는 main 함수는 query 결과나 다른 함수들을 호출하는 역할로 전체적인 기능이 무엇인지 바로 알 수 있도록 한다.       
> checkparameter 함수는 request 객체와 paramsUtil 의 함수들을 통해 파라미터를 검증하는 역할을 한다.    
> query함수는 검증된 파라미터를 이용하여 queryUtil에 있는 함수를 통해 원하는 데이터를 가져오거나 등록하는 역할을 한다.       
> 이렇게 main안에서도 역할에 따라 함수를 나누어서 작성을 한다면 나중에 기능 추가나 보완이 더 잘 이루어질 것이다! 항상 스케일업을 고려하자!!!       
> event 게시글의 조회수를 산정하는 query를 작성하였다. 그냥 간단하게 상세 정보를 호출할 때마다 count를 증가시키는 방법이 있지만       
> 더 정교한 방법을 사용하고 싶어서 사용자가 해당 event 게시글을 하루에 한번만 집계되도록 하였다.       
> 같은 사용자가 같은 게시글을 당일에 2번을 봐도 1번만 조회수가 count 될 수 있도록 하였다.       
> 사용자가 볼 때마다 log view table을 업데이트하는 procedure와 조회수를 count하는 procedure를 각각 따로 구성하였다. 
> log_view table은 사용자가 볼 때마다 insert되지만 count는 distinct를 이용하여 중복을 제거하여 count 될 수 있도록 구성하였다.      
> procedure를 사용하니까 query가 훨씬 간결해지는 것 같다.     

### 200717 mysql aws에 deployment
> WebStorm과 pem을 이용해서 aws에 코드를 배포하였다.                
> github를 이용해서 진행하는 줄 알았지만, webstorm에서 자체적으로 도와주는 tool이 있었다.     
> 그래서 보다 쉽게 deployment를 할 수 있었다.         
> 또한 code를 또 가독성을 높이기 위해 분리하였다.    
> query를 담당하는 부분이더라도 그 안에서 각 query에 대해 처리하는 함수를 각각 나누어서 코드를 작성하였다.      
> 그렇게 하면 나중에 query를 추가하거나 수정하거나 삭제할 때 좀 더 용이하게 할 수 있다.     
> 실제로도 코드를 나눌수록 보기도 편하고 그냥 봤을 때도 어떤 역할을 하는지 한눈에 볼 수 있었다.       
> query를 처리하는 query util에서도 중복되는 query는 하나의 함수로해서 재사용성을 높였다.     
> error를 처리하는 경우에도 error에 대한 응답을 errorutil이라는 파일을 만들어서 그 안에 함수로 작성하였다.        
> error util을 만들어서 router 처리하는 부분과 query 부분에서 require을 통해 보다 간결하게 처리할 수 있었다.       

### 200720 mysql connection pool
> 현재 db를 사용하는 사람이 client와 server 개발자 뿐이지만 나중에 배포해서 사용자가 늘어난 경우 db connection을 처리해주어야한다.      
> client connection이 많은 경우 connection이 이루어지지 않아서 query를 처리하기가 힘들 수 있다.      
> 그래서 connection pool을 만들어서 pool 안에 connection을 생성하고 query를 할 때마다 pool에서 connection을 가져와서 사용하면 된다.      
> 이 때 insert update delete와 같이 db에 대해 변경이 일어나는 경우, error 발생 시 데이터를 되돌리기 위해 rollback과 commit을 이용한다.     
> error가 발생해서 데이터의 변경, 수정을 되돌리기 위해서 connection.rollback()을 사용한다.     
> error가 발생하지 않고 수정사항에 대해 변경을 반영하기 위해서 connection.commit()을 사용한다.      
> query를 모두 완료한 경우 connection.release를 통해 connection을 pool에 돌려줘야 한다.        
> 만약 돌려주지 않는다면 connection pool을 사용하지 않는 것과 동일한 결과가 일어날 것 같다.    

### 200721 mysql connection pool 보완
> mysql connection pool에서 release를 try catch finally를 통해 언제든지 실행해서 pool에 connection을 반환하도록 하였다.      
> mysql connection pool에서 transaction을 실행하고 transaction이 일어나는 동안 에러가 발생하면 rollback을 통해 데이터를 삽입하거나 변경한 것을 되돌려놔야한다.      
> 그래서 rollback을 사용해서 event 조회수를 update 하는 connection에서 에러를 발생시키고 데이터의 변화를 확인해보았다.       
> error 발생 시 rollback 써서 데이터가 삽입되지 않는 것을 확인할 수 있었다.      
> 또한 query가 에러없이 잘 이루어진다면 commit을 통해 데이터 변경이 일어나도록 하였다.      
> 에러가 없는 경우 데이터베이스에 데이터가 잘 넣어지는 것을 확인할 수 있었다.        
> 이렇게 commit과 rollback을 사용한다면 여러 명의 사용자가 데이터를 변경할 때 데이터가 꼬이지 않고 진행할 수 있을 것 같다.       
> 그리고 connection pool에서 release를 하지 않고 계속 요청을 날려서 connection을 생성하면 connection이 줄어들지 않고 꽉 차 있어서 too many connections 라는 오류를 볼 수 있었다.          
> release의 중요성!!!!!!!!!!!!!!!        
> 그리고 release를 하고 계속 요청을 날렸을 때는 connection이 5개로 유지 되는 것을 볼 수 있었다.       
> release를 통해 connection을 항상 적은 개수로 유지해야한다.         
> 단일 connection이라면 connection.end()를 사용하지만, connection pool을 사용하는 경우에는 connection.release를 이용한다.  
> webstorm으로 deployment 하는 방법!        
<pre>
프로젝트 파일을 열지 않은 상태일 때, Default Settings - Build, Execution, Deployment - Deployment
프로젝트 파일을 열어둔 상태일 때, Tools - Deployment - Configuration
</pre>

### 200803 유동적인 pagination 구현
> 기존의 pagination은 한번에 10개씩 정해진 개수만큼 데이터를 가져와 client에 보내줬지만, 관리자 페이지에서 한 페이지 당 보여질 수 있는 데이터의 수를 조작할 수 있도록 구현하였기 때문에,    
> app이나 관리자 페이지에서 사용자가 정한 개수만큼 데이터를 불러올 수 있도록 유동적인 pagination을 구현하였다.     
> React 랑 서버랑 해서 사용자가 목록 테이블에서 자신이 한 페이지에서 보고싶은 데이터 수를 선택하면 그만큼 볼 수 있도록 정적인 pagination이 아닌 유동적인 pagination을 구현하였다.    
> 정적으로 하면 그냥 10페이지 이런 식으로 보여주고 나중에 이슈가 생길 수 있지만 이렇게 하면 유동적이어서 이슈가 적을 것이다.       
> 하지만 또 하다보니까 react 코드가 겹치는 부분이 많아서 나중에 정리를 해야할 것 같다.     

### 200804 관리자 페이지 검색 기능 구현
> React 관리자 페이지에서 항목에 맞게 검색을 하면 그 검색에 대해서 결과를 가져오는 작업을 함.     
> 화면에 navbar를 이용해서 검색할 수 있는 bar를 만들고 그 위에서 검색 항목에 맞게 가게면 가게, 이벤트면 이벤트, 약품이면 약품 검색을 해서 데이터를 가져오도록 하였다.     
> Mysql의 like 를 사용하면 해당 테이블의 열에 해당 문자열이 있는 데이터를 가져온다. 검색할 때 되게 유용한 query.    
> 그리고 전화 입력하는 경우에도 format에 맞게 입력되고 보여질 수 있도록 구성하였다.     
> 또한 광고를 보여주기 위해서 광고 이름과 광고 링크를 보내는 api를 만들고 swagger 작성하고 서버 요청 받는 부분 구현하였다.     
> 광고의 경우 s3에 저장된 광고 이름을 app에 전송하면 되기 때문에 간단하게 구현을 할 수 있었다.     
<pre>
=> 한 기능을 구현할 때, db query 생성 -> 서버 쪽 swagger 작성 -> 서버 쪽 api 요청 받는 쪽 작성 -> 관리자 페이지 요청 전송 -> 관리자 페이지 ui 이런 식
</pre>

### 200805 전체 검색 기능 보완 & FCM 
> React 상단에서 검색 바를 해당 항목  nav bar로 들어온 경우에 할 수 있도록 함.     
> 검색 props undefined 문제가 발생하기도 하고 안하기도 한다…ㅠ     
> 이미지 크기가 크면 앱에서 여러 개의 사진을 보여줄 때 버벅거리는 현상이 발생한다.     
> 이를 막기 위해서 앱에서도 처리해주지만 서버 관리자 페이지에서도 이미지 올리면 1mb 이하만 올릴 수 있도록 설정하였다.      
> 그리고 이미지 파일 이름 같은 경우 한글보다는 영어를 사용하자. 이미지를 app에서 보여줄 때 에러가 발생하였다.     
> 또 검색할 때도 영어는 바로 되는데 한국어는 제대로 이루어지지 않음.    
> fcm 간단하게 동작 구현. token을 이용해서 전송을 하면 여러명에게 전송할 때 제약이 있다.    
> 여러명한테 전송하려면 반복문을 돌려서 여러번 보내거나 registration 이런 식으로 방법이 있는데, 한번에 1000명만 보내야한다는 제약사항이 존재한다.      
> 그래서 topic을 사용한다. 안드로이드에서 해당 topic에 대해서 구독을 하고 서버에서 그 topic을  구독한 사람한테 전송을 할 수 있고, 이는 더 많은 사람들에게 효율적으로 전송을 할 수 있다.     

### 200806 FCM 구현
> notification은 백그라운드에서 알람 목록에 뜨게 된다. fcm에서 처리.    
> 하지만 data가 넘어가지 않는다. 왜냐 onreceiveMessage가 콜백되지 않기 때문이다.      
> 이와 달리 foreground인 경우 onreceivemessage가 콜백이 되서 data에 대해서 처리를 할 수 있다.      
> 앱이 죽은 경우나 실행하지 않는 경우 백그라운드에 속하는데 이 때 notification이랑 data랑 같이 사용하면 알람이 정상적으로 이루어지지 않는다.        
> 이와 달리 foreground인 경우 onreceivemessage가 콜백이 되서 data에 대해서 처리를 할 수 있다.      앱이 죽은 경우나 실행하지 않는 경우 백그라운드에 속하는데 이 때 notification이랑 data랑 같이 사용하면 알람이 정상적으로 이루어지지 않는다. 
> 그래서 대부분 notification 이를 사용하지 않고 data만 사용한다.       
> 그러면 앱이 실행되고 있어도, 프로세스가 중지되거나 아예 실행 안한 경우 모두 푸쉬 알람이 간다. 다만 강제종료한 경우는 제외      
> 또한 메세지를 보낼 때 json 형태로 보내야하고, 우선순위도 high로 설정해야 바로 알림이 간다. 우선순위는 마음대로 조절을 할 수가 있다. 

>  메세지 여러개 한번에 보내는 방법    
<pre>
// This registration token comes from the client FCM SDKs.
var registrationToken = 'YOUR_REGISTRATION_TOKEN';

var message = {
  data: {
    score: '850',
    time: '2:45'
  },
  token: registrationToken
};

// Send a message to the device corresponding to the provided
// registration token.
admin.messaging().send(message)
  .then((response) => {
    // Response is a message ID string.
    console.log('Successfully sent message:', response);
  })
  .catch((error) => {
    console.log('Error sending message:', error);
  });
</pre>

> 주제를 이용해서 메세지를 보내는 방법     
<pre>
// Define a condition which will send to devices which are subscribed
// to either the Google stock or the tech industry topics.
var condition = "'stock-GOOG' in topics || 'industry-tech' in topics";

// See documentation on defining a message payload.
var message = {
  notification: {
    title: '$GOOG up 1.43% on the day',
    body: '$GOOG gained 11.80 points to close at 835.67, up 1.43% on the day.'
  },
  condition: condition
};

// Send a message to devices subscribed to the combination of topics
// specified by the provided condition.
admin.messaging().send(message)
  .then((response) => {
    // Response is a message ID string.
    console.log('Successfully sent message:', response);
  })
  .catch((error) => {
    console.log('Error sending message:', error);
  });
</pre>

> 주제는 최대 5개가 한계      
> 주제에 맞게 fcm 해서 알람 보내는거 구현하였다.        
> Node schedule을 사용해서 주기적으로 fcm 알람이 갈 수 있도록 구현하였다. -> 근데 이 aniple 프로젝트에서는 광고 푸시 알람만 전송하기 때문에 이 기능은 필요가 없을 것 같다! 
> ==> 기획을 보고 알아채야 한다.      
> 관리자 페이지 목록에서 필터 기능을 제외하고, store의 경우 모든 항목을 나열해서 한번에 검색을 할 수 있도록 sql에서 and로 이어도 like “%%” 라면 모든 내용이 검색이 된다.         
> 또한 데이터 테이블 이름, 간격 수정하고, 병원은 병원끼리, 약국은 약국끼리 같은 범위에서 검색을 할 수 있도록 변경함. 그래서 페이지가 더 늘어났다.     
> —> 다만 검색할 때 버벅거리는 문제가 있고 코드의 가독성을 높여야할 것 같다.     

### 200806 뒤로가기 등 다양한 상황에서의 검색 기능 보완
> 검색하고 나서 뒤로가기 하면 아무것도 데이터를 가져오지 못했는데, url의 search 즉, 쿼리를 이용해서 이를 parsing해서 검색 조건이 무엇인지 알아내고, url의 query가 바뀔 때마다 데이터를 업데이트 할 수 있도록 구현하였다.     
> Sql procedure 들여쓰기를 이용해서 가독성을 조금이라도 높이는 것이 좋다.      
> 이미지 크기 정해진게 아니라 반응형으로 수정하였다.     
> React 관리자페이지 코드 중복되는거 약간씩 수정하여 가독성을 보다 높였다.      
> 짜잘한거 수정함 . 시간 보여지는거나 그런거      
> —> 흠 스러운거 : 병원 이런 것처럼 검색하는 부분이 아닌데 search bar가 있는게 나은지 아님 처리를 할지 , datatable 크기, mysql 시간 설정(한국 시간이 아님)    

### 200810 관리자 페이지 데이터 테이블 수정 및 보완 & 푸시 알람 페이지 구현
> 1. store 통일 시키기 (체크)   
> 2. 관리자 페이지 로고 변경하기    
> 3. 드롭다운으로 병원, 약국, 미용, 용품 이렇게 선택하면 이동할 수 있도록 한다. (체크)    
> 4. Mysql 한국 시간으로 변경(체크)       
> 5. 광고 푸시 보내기 (체크)      

> 이벤트 목록, 생성/ 약품 목록, 생성이랑 통일성을 주기 위해서 store의 경우에도 목록과 생성만 있을 수 있도록 변경하였다.    
> 그래서 기본 store 목록으로 들어가면 동물병원 목록이 먼저보이고 card header에서 병원, 약국, 미용, 용품을 select로 해서 선택하면 원하는 store type으로 이동할 수 있도록 구현하였다.     
> 또한 관리자 페이지 로고를 변경하였고, 나중에 로고 색상 변경을 해야할 것 같다.     
> 그리고 그 전에 mysql이 한국 시간이 아니라서 시간 정보가 제대로 되어있지 않았는데 한국 시간으로 변경하였다.       
> 그리고 이제 관리자 페이지에서 사용자들에게 광고를 하거나 알람을 보내기 위해서 푸시 알람을 보낼 수 있도록 화면을 구현하였다.          
> 푸시 알람 페이지를 가면 제목과 내용을 입력하고 입력한 내용을 서버에 보내서 푸시 알람을 보낼 수 있도록 구현을 하였다.        
> aniple의 경우 특정 사용자가 존재하지 않아서 topic 하나로 푸시 알람을 보낼 수 있도록 구현을 하였다.       
> 푸시 알림은 디비에 저장할 필요가 없다!

### 200811 푸시 알람 페이지 보완 & 검색 bar 보완 & aws 배포
> 1. 데이터 테이블이 아닌 경우 search bar가 안보이도록 한다.      
> -> url를 읽어서 해당 url이 데이터 목록인지 아닌지를 구별하여 search bar를 보일지 말지를 결정하였다.       
> 2. 로고 색깔 변경하기    
> 3. 푸시 알람 작성할 때 글자수 1/140 이런 식으로 보일 수 있도록 수정      
> -> input tag에 maxLength 속성을 이용하면 된다.      
>   maxLength = “140” 이렇게 설정을 하면 140자로 입력이 제한된다. (공백포함)     
> 4. 검색했을 때 검색 bar 보이게 하고 검색 결과 화면에서 동물 병원, 약국, 미용실, 용품점 select하면 검색 파라미터를 이용해서 각 store 풋종류에 맞게 검색하여 결과를 보여줄 수 있도록 구현       
> -> 검색 화면에서 검색하고 나서 다른 store 종류를 보고자 할 때 select tag를 이용해서 선택할 수 있도록 하였다.        
>   이 때 그냥 해당 store 타입 목록으로 이동하는 것이 아니라 검색 파라미터? 검색하고자 하는 내용을 이용해서 검색 결과 화면으로 이동할 수 있도록 구현하였다.         
> 5. Aws 위에 관리자 페이지 배포를 함, pm2 를 이용해서 중단없이 실행할 수 있도록 구현      
> -> react project를 pm2를 이용하여 작동을 시키려면 pm2 start —name “app name” — start 로 실행시키면 된다.        
<pre> 
pm2 start --name "app name" --start
</pre>

### 200812 로그인 구현 & 로그인 유지 & jwt 토큰
> 1. 관리자 페이지 api 스웨거 제거(체크)     
> 2. 관리자 유저 데이터 테이플 생성(체크 -> 검사맡기)      
> 3. 로그인 api 구현(서버) (체크)         
> 4. 로그인 암호화, 서버 전송 구현(체크)       
> 5. Url 못타고 들어가게 막기 로그인 안되어 있으면 로그인 할 수 있도록 중요!! (체크 -> 검사맡기)       
> 6. 로그아웃          

￼￼![image](https://user-images.githubusercontent.com/52439497/89996427-baddfd80-dcc5-11ea-9afc-dd9a413ba3e0.png)

> https를 사용한다면 프론트에서 굳이 비밀번호를 암호화를 할 필요가 없다.         
> 프론트엔드에서 암호화는 큰 의미를 가지고 있지 않다. 그렇기 때문에 프론트에서는 비밀번호를 대체로 암호화하지 않고 백엔드 서버에서 데이터 베이스에 비밀번호를 저장할 때 그대로 저장하지 않고 암호화를 시켜서 저장을 한다.              
> 따라서 프론트에서는 비밀번호를 그냥 평문으로 보내고 백엔드에서 해시함수를 사용하던가 암호화를해서 저장하고, 로그인 시에는 평문으로 받은 비밀번호를 데이터 베이스에 저장할 때와 같이 암호화하여 같은지를 체크하면 된다.               
> Node crypto module을 사용해서 서버 단에서 사용자의 비밀번호를 암호화하여 비교하는 것을 구현하였다.        
> 암호화는 pbkdf2와 sha 256 을 이용해서 길이가 64의 암호화 된 key를 만들었다.         
> 이 때 salt값이 사용이 되는데 이 salt 값은 crypto module의 randomBytes를 사용하여 랜덤으로 만들어버렸다. 그렇기 때문에 사용자마다 생성된 salt값은 db에 저장하여 알고 있어야한다.         

> 로그인 인증 => react는 token을 저장하고 인증을 받도록 한다.       
> 로그인 유지는 로그인을 하고 나서  express 서버에서 로그인 성공시 발급 받은 token을  localstorage에 저장을 하고, 로그인 성공 여부에 대해서도 localstorage에 저장한다.         
https://github.com/coreui/coreui-free-react-admin-template/issues/113              
> 이후에 router들을 렌더링 할 때          
> 로그인이 필요한 AuthenticationedRoute와 로그인이 필요하지 않은 UnauthenticatedRoute를 만들어서, localstorage에 token이 존재하고 login이 성공이라면 인증이 된 것이므로 authenticated route를 렌더링해서 보여줄 수 있다.         
> 로그인 페이지의 경우 인증이 필요하지 않은 route이기 때문에 unauthenticatedRoute로 설정한다. 하지만 뭔가 굳이 Unauthenticated로 굳이 할 필요는 없어보인다.             
> 이렇게해서 인증이 되지 않은 사용자는 페이지에 접속을 할 수 없도록 구현하였고, 로그인 유지에 대해서도 어느정도 구현을 하였다.         
> localstorage에 로그인 여부가 성공이고 token이 만료되지 않은 경우 자동로그인이 되어 유지를 할 수 있다.             
> —> 근데 로컬스토리지를 사용해서 저장하는게 괜찮은 방법인가라는 생각이 들었다.         
> ==> 다음 할 일 : 관리자 페이지에서 요청을 보낼 때 토큰을 넘겨서 이 토큰이 verify 된건지 검증을 해야한다.               
> 검증을 했는데 만약 만료된 토큰이라면 react에서 만료된 사실을 알고 로컬 스토리지의 로그인 여부를 실패로하고 토큰을 지워야한다. 로그아웃      
> Theheader에 사용자 이름이랑 로그아웃 버튼 만들기       

### 200813 로그인 시 사용자 정보 저장 & jwt 토큰 만료 확인 
> 1. 요청할 때 token 해서 jwt 만료됐는지 아닌지 확인하기(서버).   
> 2. 로그아웃 버튼 만들고 , 사용자 아이디 띄우기 (체크).   
> 3. 로그아웃 기능 만들기 (체크).      
> 4. 병원 정보 db에 넣기 (체크).    

> 출처 : https://pro-self-studier.tistory.com/50?category=658753.    


#### Redux 사용순서
![image](https://user-images.githubusercontent.com/52439497/90316681-a9fbe900-df5e-11ea-894d-c02e240cf3c4.png)


> 여러가지를 한번에 import하는 방법       
![image](https://user-images.githubusercontent.com/52439497/90316692-cc8e0200-df5e-11ea-970f-40a53ba8b09e.png)


> redux에서 데이터를 가져오는 방법      
> => dispatch를 이용해서 action을 실행하여 state에 데이터를 저장한다.         
> 이 때 함수형 컴포넌트라면 useDispatch를 이용해서 dispatch를 선언하고나서 사용할 수 있다.         
> dispatch를 이용해서 state에 데이터를 저장하고, useSelector를 이용해서 state에 있는 데이터들을 가져올 수 있다.       
> 이 때 여러 action?에 대해서 action을 감지하는 reducer가 여러개가 선언이 될 수 있는데,          
> 이 때 reducer가 여러개라면 combineReducer를 사용하여 reducer를 하나로 합치고 createStore를 통해 store를 만들어 사용할 수 있다.          
> https://velog.io/@eomttt/Redux-%EC%A0%81%EC%9A%A9%ED%95%98%EA%B8%B0-%ED%95%A8%EC%88%98%ED%98%95-Class-%ED%98%95           
> -> 함수형 컴포넌트를 사용한 경우 참조       

> 대신 state의 경우에는 데이터가 새로고침하면 사라진다. 그래서 유저정보를 localstorage에 저장.      
> 상단에 보이는 유저 정보들은 로그인 시에 로컬스토리지에 저장을 하고, 로그아웃을 하면 로컬스토리지에서 삭제를 한다.         

> 요청을 보낼 때마다 권한이 있는지 없는지 확인하기 위해서 서버 쪽에서는 authenticate util에 jwt를 검증하는 authenticate function을 정의하고,       
> 정의한 함수를 라우터에 요청이 들어오자마자 실행하여 권한을 확인하도록 구현하였다.         
> —> <이슈> 인터셉터 역할 => 근데 모든 api에 일일이 하지 않고 그냥 /admin으로 오는 요청을 한번에 처리할 수 없을까..         
> 그리고 권한 인증이 되면 서버에서는  authentication이라는 이름으로  header를 설정한다. 인증이 되면 true, 인증이 되지 않으면 false로 설정하였다.           
> 이 때 중요한 점은 client에서 서버의 custom header에 접근하기 위해          
<pre>
const corsOptions = {
  exposedHeaders: 'authentication',
};
app.use(cors(corsOptions));
</pre>

> 이런 식으로 cors를 설정해야한다.  그러면 client에서 custom header에 접근할 수 있다.        

> 그리고나서 클라이언트 쪽에서는 모든 api 응답에서 header를 확인하고 authentication이 참인지 거짓인지를 판단하여 권한에 대해서 판단을 한다.          
> 만약 권한이 없다면 (토큰이 만료되는 등) 다시 로그인하라고 alert를 통해 알려주고 localstorage의 내용을 다 지우고 로그인 페이지로 이동하도록 하였다.         

> —> 다음 할일 : 토큰 만료에 대해서 처리 이 부분은 뭔가 에러가 계속난다…ㅠ, 그리고 용품이 카페로 변경이 되었으니 용어는 웬만하면 고쳐라, 거리 알려줄 때 파라미터로 거리 입력받으면 그만큼 받아오도록 처리할 수 있도록       

### 200814 토큰 만료 보완 & 자잘한 수정 
> 1. 토큰 만료에 대해서 처리(체크)      
> 2. 거리에 대해 파라미터를 알려주면 파라미터 받아서 처리할 수 있도록(체크)         
> 3. 용품 -> 카페 로 용어 고치기        
> 4. 로그인 버그 발견 -> 비밀번호가 틀린데도 로그인 성공이 된다.  (버그 수정)        
> 5. 로그아웃 버튼,  user 정보 반응형        

> -> 토큰 만료가 되면 토큰 만료 에러를 클라이언트에서 던져서 해당 에러에 대해서 처리할 수 있도록 한다.           
> 로컬 스토리지에 있는 정보를 삭제를 하고 로그인 페이지로 이동할 수 있도록 구현하였다.         
> 그리고 로그인 시 crypto모듈이 비동기적으로 진행이 되어서 promise로 만들어서 비동기식으로 고쳐서 결과가 제대로 도출되고 진행될 수 있도록 구현하였다.        

> —> 다음 할일 : 용품점이름을 카페로 모두 수정, 로그아웃, user 정보 반응형으로 고치기, 홈으로 가면 sidebar가 클릭된 것처럼 보이게 해야한다.         
> -> 로그아웃, 유저 정보 반응형으로 고치기        
> ==> react-responsive 를 이용해서 MediaQuery를 이용해서 max - width, min - width를 이용해서 max width랑 min width를 정해서 해당 width 이상이거나 이하이면 다르게 보이도록 반응형으로 구현            
> -> 용품점 모두 카페로 변경, method 같은 경우도 변경함.      

##### aniple project 마무리 


### 200818 자잘한 부분 수정
> 1. 개인정보처리방침 html 서버에 올리기     
> => html 을 올리려면 웹 서버가 필요한데 express 웹서버에 html을 올려서 사용함     
> Cmd option l 해서 코드 정렬 ! 그리고 코드 잘 보자!       
> <이슈>     
> 또한 express에서 public에 html 파일 올리고       
<pre>
app.use('/static',express.static(path.join(__dirname, 'public')));
</pre>

> 이렇게 하면 주소:3000/static/파일명 이렇게 접근할 수 있다.       

> Html 올리는 것을 어렵게 생각하지말자!        
> 2. 사이드 바에서 새로고침하면 선택된거 보이게 하는거…       
> => 브랜드 아이콘 누르면 새로고침해서 사이드바 보이도록 수정함        
> 근데 redirect인 경우는 수정하지 않음ㅠㅠㅠ      
> 1. UI 부분 자잘한거 수정         
> 2. 이미지 로드시 이미지가 없는 경우 에러 이미지를 보여줄 때        
<pre>
onError={(e) => {
  e.target.onerror = null;
  e.target.src = errorImg;
}
</pre>
> 이렇게 하면 된다.      
<pre>
<img alt ="동물 병원 이미지" src={`https://aniple.s3.ap-northeast-2.amazonaws.com/store/${item.image_name}`}
     onError={(e) => {
       e.target.onerror = null;
       e.target.src = errorImg;
     }}
     style={{
       width: "auto",
       height: "auto",
       maxHeight: "600px",
       maxWidth: "100%"
     }}/>
</pre>
> img 태그에 onError 이벤트에 대해서 처리하도록 하고, 이벤트가 발생한 이미지에 대해서 src를 수정해서 에러이미지를 보이도록 하였다.      



### 200820 새 프로젝트 준비(WebStorm deployment시 sftp 에러 발생 -> aniple이 아니라 다른 key도 에러가 난다.)
> Ubuntu ec2설정에서 sftp 연결에 오류가 발생하였다.      
> 왜 연결이 안되는지 잘 모르겠다..      
> Filezila 이용해서 업로드하면 잘 반영되는 것 같은데..      
> —> 이슈 발생한 것 같다. ec2를 재부팅하니까 sftp 프로토콜을 연결할 수 없다는 에러가 발생하였다.            
<pre> 
Unknown scheme in uri sftp error  
</pre>
> Datagrip 사용할 때, table 우클릭하고 jump to query console 하면 query 쓰고 실행할 수 있다.      
> ec2에서 node 설치하는 방법      
<pre>
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
> sudo apt-get install -y nodejs
</pre>
> 보안그룹 생성 시 port => http, https , ssh, mysql 위치무관으로    
> aws ec2, RDS, S3를 세팅하고, datagrip을 이용해서 dump 진행       


### 200821 DoItPower 서버 검토 및 준비
> dotenv -> aws access key 나 비밀번호 계정 정보 등 팀원끼리 공유하지만 외부에 새어나가면 안되는 데이터를 .env 파일로 해서 보안해주면서 저장하는 도구        
> Npm install로 설치하면 될 것 같다.       
> Api 응답, 에러 처리할 때       
![image](https://user-images.githubusercontent.com/52439497/90869453-32e9a900-e3d3-11ea-810d-11061a1ce6ed.png)
> 이런 식으로 처리하면 좋을 것 같다. -팀장님 소스 참고     

##### <정리>
> 1. Error        
> 에러 발생 시 생성되는 error code를 따로 빼서 정리하는게 좋을 것 같다. Err code  파일을 따로 만들어서 module.export하면 될 것 같다.       
> error.stack -> 에러 발생 시 추적 정보를 담고 있다.         
> Error Util은 에러가 발생하면 가져오고, 에러를 초기화 하는 코드, 특정 상황에 대한 에러를 에러 메세지를 포함하여 생성할 때 필요한 코드, 마지막으로 throw error해서 에러를 던진다.   

> 2. hashUtil        
> 비밀번호 잃어버렸을 시에 랜덤으로 비밀번호 만드는 코드 !!!         
> Crypto 이용해서 진행하면 된다. randomBytes이용      

> 3. Mysql         
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

> 4. nodeMailer       
> 이 모듈을 이용해서 사용자에게 메일을 보낼 수 있다.       

> 5. sendUtil         
> Sendutil 을 따로 만들어서 메일을 보내든, 서버에 에러를 보내든 보내는 부분에 대한 기능을 따로 빼서 진행     

> 6.  로그인  
![image](https://user-images.githubusercontent.com/52439497/90869768-a8557980-e3d3-11ea-9ff5-df45f81f59e0.png)

> 이런 식으로 로그인 사용자만 접근할 수 있는 api와 누구나 접근할 수 있는 api를 나누어서 api를 구성하는 것이 좋다.       
> 그래서 private인 api는 중간에 middleware를 설정해서 사용자를 확인할 수 있도록 한다.       
> app.all(‘/~ 이 부분에서 로그인을 확인할 수 있는 middleware를 설정한다.        

##### <팁>
> 1.  사용자가 사용하다가 버그가 발생하면 어떤 운영체제에서, 어떤 앱 버전에서 발생했는지 알아야 쉽게 버그를 고칠 수 있기때문에 user table에 app버전이랑 os를 표시하는 column을 추가하는 것이 좋다.        
> 그리고 로그인 할 때마다 혹은 회원가입 할 때 사용자의 os와 앱 버전을 새로 수정하는 것이 좋다.        

> 2. nodemailer를 이용해서 서버에서 메일을 사용자에게 전송을 할 수 있는데, 이 때 에러가 발생한다.           
> 대부분 에러는 보안 이슈 때문인데, 보내고자 하는 메일의 보안을 낮추면 메일을 서버에서 대신 전송할 수 있다.         

> 3. 중요한 api를 전송하거나 그런 경우는 log를 따로 기록해놓는 것이 좋다.      

> 4. Update 하는 procedure에서       
> Update 를 시작하기 전에 set sql_safe_updates = 0; 이 명령어를 진행해서 safe update mode를 끄는 것이 좋다.        
> 그리고 update를 다하면 set sql_safe_updates = 1; 를 해서 원상복구 해야한다.        
> 5. Table 간 join! Inner join과 outer join이 존재한다.         
> 여기서는 내가 참여하는 contest 목록을 가져올 때 contest member 테이블이랑 contest team 테이블과 각각 join해서 내 uid랑 맞는 contest를 가져온다.         

> 6. Mysql ifnull(값, 대체할 값)         

> 7. AWS S3에 사진을 올릴 때, 해당 파일의 mimetype.startWith 를 이용해서              
> 이미지라면 ‘image/‘로 시작하는지, ‘audio/’ 이런 식으로 시작하는지를 통해 파일 유형을 알아낼 수 있다. => fileFilter 로 해서 multerOptions을 만들고 거기에 넣을 수 있다.       

![image](https://user-images.githubusercontent.com/52439497/90870008-f8ccd700-e3d3-11ea-8b66-c757051e7b89.png)

> 8. Node에서 이미지 처리에 sharp 모듈이 유명           
> -> 이미지 resize, 확장, 이미지 추출, 이미지 처리 등 이미지를 사용할 때 유용한 라이브러리이다.            
> 특히 한 이미지에 대해서 썸네일 사진이 필요한 경우,  원본 이미지를 resize 시켜서 따로 섬네일 사진을 만드는 것이 좋다.        


### 200824 DoItPower contest api 구현 시작
> Contest 상세 페이지 가져올 때, db procedure를 보완하였다.         
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






