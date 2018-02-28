# -*- coding: utf-8 -*-
# テスト
# gunicorn -b {192.168.11.5(9)}:8000 FakeInjection_server:api　でサーバ立ち上げ
import falcon # ==1.3.0 by pip
import serial # ==3.4 by pip
import json, datetime, time, sys, threading # 標準

ser = serial.Serial('/dev/tty.usbmodem1421',9600,timeout=1)
# Arduinoから送られてくる時間[ms]を格納
data_list = []
# iPhoneの各イベントの絶対時刻[s]が格納
second_list = []
# 動画が逆再生モードか否か
isModeReverse = True

# Arduinoの受信
def recvThread():
    global data_list
    global second_list
    global isModeReverse
    c = 0
    while True:
        readdata = ser.readline()
        readdata = readdata.strip().decode('utf-8')
        if readdata != "":
            data_list.append(readdata)
            c += 1
            if c == 1:
                print("Start || Touch", data_list[0], "[ms]")
            elif c == 2:
                print("Touch || Max", data_list[1], "[ms]")
            elif c == 3:
                if not(isModeReverse):
                    print("Max || Loosen", data_list[2], "[ms]")
                elif (len(second_list) < 2 and isModeReverse == True):
                    print("Fast Loosen!")
                    print("Max || Loosen 0 [ms]")
                else:
                    r_time = round((second_list[1] - second_list[0]),3)
                    tmp = int(data_list[0]) + int(data_list[1]) + int(data_list[2]) - (1000*r_time)
                    print("Reverse || Loosen", tmp, "[ms]")
            elif c == 4:
                print("Loosen || Leave", data_list[3], "[ms]")
                c = 0

recvT = threading.Thread(target=recvThread)
recvT.start()

# 絶対時間を返す
def nowTime():
    now = datetime.datetime.now()
    now_time = now.strftime("%Y/%m/%d %H:%M:%S:%f")
    tmp1 = now_time.split(" ")
    tmp2 = tmp1[1].split(":")
    second = 24*60*int(tmp2[0]) + 60*int(tmp2[1]) + int(tmp2[2]) + 0.000001*int(tmp2[3])
    return second

class ItemsResource:
    def on_post(self, req, res, dataType):
        global data_list
        global second_list
        global isModeReverse

        body = req.stream.read().decode('utf-8')
        data = json.loads(body)

        if dataType == "start":
            person = data['person']
            reverseTime = data['reverseTime']
            print("Person -", person)
            print("ReverseTime -", reverseTime, "[s]")

            tmp = data['isModeReverse']
            if tmp == "true":
                isModeReverse = True
            else:
                isModeReverse = False

            now = datetime.datetime.now()
            now_time = now.strftime("%Y/%m/%d %H:%M:%S:%f")
            # サーバ基準の時間系で計測
            print("Start = ", now_time)
            start_time = nowTime()
            second_list.append(start_time)

            # Arduinoに書き込み
            flag=bytes('s','utf-8')
            ser.write(flag)

        if dataType == "reverse":
            # サーバ基準で、StartからReverseまでの正しい時間
            reverse_time = nowTime()
            second_list.append(reverse_time)
            r_time = round((reverse_time - second_list[0]),3)
            if len(data_list) < 2:
                print("Late Max!")
            else:
                tmp = (1000*r_time) - int(data_list[1]) - int(data_list[0])
                print("Max || Reverse", tmp, "[ms]")

        if dataType == "end":
            # サーバ基準で、StartからEndまでの正しい時間
            end_time = nowTime()
            e_time = round((end_time - second_list[0]),3)
            if len(data_list) < 4:
                print("Late Leave!")
            else:
                tmp = (1000*e_time) - (int(data_list[0])+int(data_list[1])+int(data_list[2])+int(data_list[3]))
                print("Leave || End", tmp, "[ms]")

            data_list = []
            second_list = []

api = falcon.API()
api.add_route('/{dataType}', ItemsResource())
