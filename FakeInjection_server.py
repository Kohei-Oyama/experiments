# -*- coding: utf-8 -*-
# gunicorn -b {192.168.11.5(9)}:8000 FakeInjection_server:api　でサーバ立ち上げ
import falcon # ==1.3.0 by pip
import serial # ==3.4 by pip
import json, datetime, time, sys, threading # 標準

ser = serial.Serial('/dev/tty.usbmodem1411',9600,timeout=1)
data_list = []
second_list = []

def recvThread():
    global data_list
    global second_list
    c = 0
    while True:
        readdata = ser.readline()
        readdata = readdata.strip().decode('utf-8')
        if readdata != "":
            data_list.append(readdata)
            c += 1
            if c == 1:
                print("Start || Touch", data_list[0],"[ms]")
            elif c == 2:
                print("Touch || Max", data_list[1],"[ms]")
            elif c == 3:
                tmp = (1000*second_list[1]) - int(data_list[1]) - int(data_list[0])
                print("Reverse || Max_leave", int(data_list[2]) - tmp,"[ms]")
            elif c == 4:
                print("Max_leave || Leave", data_list[3],"[ms]")

recvT = threading.Thread(target=recvThread)
recvT.start()

class ItemsResource:

    def on_get(self, req, resp):
        print("GET")

    def on_post(self, req, res, dataType):
        body = req.stream.read().decode('utf-8')
        data = json.loads(body)

        global data_list
        global second_list

        if dataType == "start":

            person = data['person']
            reverseTime = data['reverseTime']
            print("Person -", person)
            print("ReverseTime -", reverseTime, "[s]")

            startTime_iphone = data['startTime']
            now = datetime.datetime.now()
            now_time = now.strftime("%Y/%m/%d %H:%M:%S:%f")

            tmp_i = startTime_iphone.split(":")
            tmp_s = now_time.split(":")
            s_second = 60*int(tmp_i[1]) + int(tmp_i[2]) + 0.001*int(tmp_i[3])
            r_second = 60*int(tmp_s[1]) + int(tmp_s[2]) + 0.000001*int(tmp_s[3])
            diff = round((r_second - s_second),3)
            #print("diff -",diff,"[s]")
            # サーバ基準の時間系で計測
            print("Start = ", now_time)
            second_list.append(s_second)

            flag=bytes('s','utf-8')
            ser.write(flag)

        if dataType == "reverse":
            reverseTime_iphone = data['reverseTime']
            tmp_r = reverseTime_iphone.split(":")
            r_second = 60*int(tmp_r[1]) + int(tmp_r[2]) + 0.001*int(tmp_r[3])
            r_time = round((r_second - second_list[0]),3)
            tmp = (1000*r_time) - int(data_list[1]) - int(data_list[0])
            print("Max || Reverse", tmp,"[ms]")

            second_list.append(r_time)

        if dataType == "end":
            endTime_iphone = data['endTime']
            now = datetime.datetime.now()
            now_time = now.strftime("%Y/%m/%d %H:%M:%S:%f")
            tmp_e = now_time.split(":")
            e_second = 60*int(tmp_e[1]) + int(tmp_e[2]) + 0.000001*int(tmp_e[3])
            e_time = round((e_second - second_list[0]),3)
            print("Leave || End", (1000*e_time) - (int(data_list[0])+int(data_list[1])+int(data_list[2])+int(data_list[3])),"[ms]")

            data_list = []
            second_list = []

api = falcon.API()
api.add_route('/{dataType}', ItemsResource())
