curl -X POST http://localhost:5001/Sequential \
     -H "Content-Type: application/json" \
     -d '{"Age": 9, "IQ": 5, "Q1": 0, "Q2": 0, "Q3": 1, "Q4": 1, "Q5": 1, "Time Seconds": 100}'

curl -X POST http://127.0.0.1:5001/Visual \
     -H "Content-Type: application/json" \
     -d '{"Age": 9, "IQ": 5, "Q1": 1, "Q2": 1, "Q3": 0, "Q4": 1, "Q5": 0, "Time Seconds": 100}'

curl -X POST http://127.0.0.1:5001/Lexical \
     -H "Content-Type: application/json" \
     -d '{"Age": 9, "IQ": 5, "Q1": 0, "Q2": 0, "Q3": 0, "Q4": 1, "Q5": 0, "Time Seconds": 100}'     

curl -X POST http://127.0.0.1:5001/Verbal \
     -H "Content-Type: application/json" \
     -d '{"Age": 9, "IQ": 5, "Q1": 1, "Q2": 1, "Q3": 0, "Q4": 1, "Q5": 0, "Time Seconds": 100}'          

curl -X POST http://127.0.0.1:5001/Ideognostic \
     -H "Content-Type: application/json" \
     -d '{"Age": 9, "IQ": 4, "Q1": 1, "Q2": 1, "Q3": 1, "Q4": 0, "Q5": 0, "Time Seconds": 100}'    

curl -X POST http://127.0.0.1:5001/Operational \
     -H "Content-Type: application/json" \
     -d '{"Age": 9, "IQ": 4, "Q1": 1, "Q2": 0, "Q3": 1, "Q4": 0, "Q5": 0, "Time Seconds": 100}' 

curl -X POST http://127.0.0.1:5001/Graphical \
     -H "Content-Type: application/json" \
     -d '{"Age": 10, "IQ": 4, "Q1": 1, "Q2": 1, "Q3": 0, "Q4": 0, "Q5": 0, "Time Seconds": 100}' 

curl -X POST http://127.0.0.1:5001/Practo \
     -H "Content-Type: application/json" \
     -d '{"Age": 10, "IQ": 5, "Q1": 0, "Q2": 0, "Q3": 1, "Q4": 0, "Q5": 1, "Time Seconds": 197}'


http://20.198.26.94:5001/

curl -X POST http://20.244.32.223:5001/Visual \
     -H "Content-Type: application/json" \
     -d '{"Age": 10, "IQ": 5, "Q1": 1, "Q2": 0, "Q3": 0, "Q4": 0, "Q5": 0, "Time Seconds": 220}'

http://20.244.32.223:5001/predictShape
 

curl -X POST -F 'file=@/Users/macbookpro2018/Desktop/SLIIT/Research/dataset/test/circle/circle-2009.jpg' http://localhost:5001/predictShape
