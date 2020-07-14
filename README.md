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

