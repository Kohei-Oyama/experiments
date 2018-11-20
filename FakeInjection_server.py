# -*- coding: utf-8 -*-
# PC側からiPhoneの操作を可能にするため
# gunicorn -b {192.168.11.123}:8000 FakeInjection_server:api　でサーバ立ち上げ
import falcon # ==1.4.1 by pip
import json, datetime, time, sys, threading # 標準

# 用意ができたか否か
goSign = False
flag1 = False
flag2 = False
count = 0

def f():
    while(True):
        c = sys.stdin.read(1)
        if c == "t":
            goSign = True
            flag1 = True
            break
        else:
            goSign = False
    print("Step 2")
    while(True):
        c = sys.stdin.read(1)
        if c == "h":
            flag2 = True
            break
    print("Step 3")
    while(True):
        c = sys.stdin.read(1)
        if c == "e":
            sys.exit()

class ItemsResource:
    # クライントから受け取った情報
    def on_get(self, req, resp, dataType):
        global goSign
        global count
        if count == 0:
            th = threading.Thread(target=f,name="th",args=())
            # スレッドthの作成　targetで行いたいメソッド,nameでスレッドの名前,argsで引数を指定する
            th.setDaemon(True)
            # thをデーモンに設定する。メインスレッドが終了すると、デーモンスレッドは一緒に終了する
            th.start()
            #スレッドの開始

        if dataType == "start" and flag2:
            print("get", flush=True)
            obj = {
                "isModeReverse": True,
                "time": 15
            }
            resp.body = json.dumps(obj, ensure_ascii=False)
        if dataType == "go" and flag1:
            print("go", flush=True)
            obj = {
                "goSign": goSign,
            }
            resp.body = json.dumps(obj, ensure_ascii=False)

api = falcon.API()
api.add_route('/{dataType}', ItemsResource())
