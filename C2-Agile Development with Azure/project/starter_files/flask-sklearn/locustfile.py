import time
from locust import HttpUser, task, between

class QuickstartUser(HttpUser):
    wait_time = between(1, 2)

    @task
    def home_page(self):
        self.client.get("/")
      
    @task
    def prediction(self):
        self.client.post("/predict", 
            json={"CHAS": { "0":0 },
                  "RM":{ "0":6.575 },
                  "TAX":{ "0":296.0 },
                  "PTRATIO":{ "0":15.3 },
                  "B":{ "0":396.9 },
                  "LSTAT":{ "0":4.98 }         
            })