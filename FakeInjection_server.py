# -*- coding: utf-8 -*-
# PC側からiPhoneの操作を可能にするため
# gunicorn -b {192.168.11.123}:8000 FakeInjection_server:api　でサーバ立ち上げ
import falcon # ==1.4.1 by pip
import json, datetime, time, sys, threading # 標準

# 動画が逆再生モードか否か
isModeReverse = True

class ItemsResource:
    # クライントから受け取った情報
    def on_get(self, req, resp, dataType):
        if dataType == "start":
            print("get")
            obj = {
                "isModeReverse": True,
                "time": 15
            }
            resp.body = json.dumps(obj, ensure_ascii=False)

    def on_post(self, req, res, dataType):
        if dataType == "start":
            print("Posted")

api = falcon.API()
api.add_route('/{dataType}', ItemsResource())
