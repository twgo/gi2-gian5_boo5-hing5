FROM localhost:5000/siann1-hak8_boo5-hing5:88

MAINTAINER sih4sing5hong5

ENV CPU_CORE 32

##  匯入語料
WORKDIR /usr/local/pian7sik4_gi2liau7/
RUN git pull

WORKDIR /usr/local/hok8-bu7/
RUN rm -rf db.sqlite3
RUN python3 manage.py migrate
RUN pip3 install --upgrade https://github.com/twgo/twisas/archive/master.zip

RUN python3 manage.py migrate
RUN python3 manage.py 匯入台文語料庫2版 valid /usr/local/gi2_liau7_khoo3/twisas2.json
RUN python3 manage.py 匯入台文語料庫trs valid /usr/local/pian7sik4_gi2liau7/twisas-trs/twisas-HL-kaldi.json


## 匯出語料
RUN python3 manage.py 匯出Kaldi格式資料 --資料夾 tshi3 臺語 拆做聲韻 $KALDI_S5C
RUN python3 manage.py 轉Kaldi音節text 臺語 $KALDI_S5C/tshi3/train/ $KALDI_S5C/tshi3/train_free

WORKDIR $KALDI_S5C
RUN git pull
RUN bash -c 'rm -rf exp/{tri1,tri2,tri3,tri4}/decode_train_dev*'

RUN sed 's/nj\=[0-9]+/nj\=8/g' -i 走評估.sh
RUN bash -c 'time bash -x 走評估.sh data/lang_free tshi3/train_free'

RUN bash -c 'time bash 看結果.sh'
