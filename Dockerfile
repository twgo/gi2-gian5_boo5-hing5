FROM dockerhub.iis.sinica.edu.tw/siann1-hak8_boo5-hing5:96

MAINTAINER sih4sing5hong5

ENV CPU_CORE 4

##  匯入語料
WORKDIR /usr/local/pian7sik4_gi2liau7/
RUN git pull

WORKDIR /usr/local/hok8-bu7/
RUN rm -rf db.sqlite3
RUN python3 manage.py migrate

RUN echo 匯入TW01Test當作仝語者
RUN pip3 install --upgrade tw01
RUN python3 manage.py 匯入TW01Test當作仝語者 /usr/local/pian7sik4_gi2liau7/TW01TestAll

## 匯出語料
RUN python3 manage.py 匯出Kaldi格式資料 --資料夾 tshi3 臺語 拆做聲韻 $KALDI_S5C
RUN python3 manage.py 轉Kaldi音節text 臺語 $KALDI_S5C/tshi3/train/ $KALDI_S5C/tshi3/train_free

## 準備 8K wav.scp 模擬電話音質
RUN sed -i -z 's/\n/avconv -i - -f wav -ar 8000 - \|\n/g' $KALDI_S5C/tshi3/train_free/wav.scp

WORKDIR $KALDI_S5C
RUN git pull
COPY conf/mfcc.conf conf/mfcc.conf
RUN bash -c 'rm -rf exp/{tri1,tri2,tri3,tri4}/decode_train_dev*'
RUN sed 's/nj\=4/nj\=1/g' -i 走評估.sh
RUN bash -c 'time bash -x 走評估.sh data/lang_free tshi3/train_free'

RUN echo 看結果
RUN bash -c 'time bash 看結果.sh'
