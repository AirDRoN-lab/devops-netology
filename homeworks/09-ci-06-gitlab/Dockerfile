FROM centos:7
RUN yum install python3.8 python3-pip -y
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
WORKDIR /python_api
COPY python_api.py python_api.py
ENTRYPOINT ["python3" , "python_api.py"]
