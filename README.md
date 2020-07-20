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
> 
