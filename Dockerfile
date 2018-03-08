FROM siann

MAINTAINER sih4sing5hong5

ENV CPU_CORE 4

##  匯入語料
WORKDIR /usr/local/pian7sik4_gi2liau7/
RUN git pull

WORKDIR /usr/local/hok8-bu7/
RUN rm -rf db.sqlite3
RUN python3 manage.py migrate

RUN python3 manage.py 匯入TW01Test /usr/local/pian7sik4_gi2liau7/TW01TestAll

RUN bash -c 'curl https://raw.githubusercontent.com/sih4sing5hong5/forpa-lexicon/master/%E5%8F%B0%E8%AA%9E%E6%96%87%E6%9C%AC/%E4%BE%8B%E5%8F%A5.%E5%88%86%E8%A9%9E.gz > 台語.txt.gz'

## 匯出語料佮語言模型
RUN python3 manage.py 匯出Kaldi格式資料 --語言文本 台語.txt.gz --資料夾 tshi3 臺語 $KALDI_S5C


WORKDIR $KALDI_S5C
RUN utils/prepare_lang.sh tshi3/local/dict "<UNK>"  tshi3/local/lang tshi3/lang_dict


ENV LM_tai5 tshi3/tai5-1.arpa
ENV LM3_tai5 tshi3/tai5-3.arpa
ENV LM_tai5_GZ tshi3/tai5-1.arpa.gz
ENV LM3_tai5_GZ tshi3/tai5-3.arpa.gz

RUN bash -c 'gzip -dc /usr/local/hok8-bu7/台語.txt.gz > tshi3/台語.txt'

WORKDIR /usr/local/kaldi/tools
RUN curl 'http://www.speech.sri.com/projects/srilm/srilm_download.php' -H 'Host: www.speech.sri.com' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:57.0) Gecko/20100101 Firefox/57.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Language: zh-TW,zh;q=0.8,en-US;q=0.5,en;q=0.3' --compressed -H 'Referer: http://www.speech.sri.com/projects/srilm/download.html' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' --data 'WWW_file=srilm-1.7.2.tar.gz&WWW_name=Sing-Hong&WWW_org=AS&WWW_address=&WWW_email=ihcaoe%40mail.com&WWW_url='  > srilm.tgz
RUN apt-get install gawk
RUN extras/install_srilm.sh 


WORKDIR $KALDI_S5C
RUN /usr/local/kaldi/tools/srilm/bin/i686-m64/ngram-count -text tshi3/台語.txt -order 3 \
    -prune 1e-4 -lm $LM_tai5
RUN /usr/local/kaldi/tools/srilm/bin/i686-m64/ngram-count -text tshi3/台語.txt -order 3 \
    -prune 1e-7 -lm $LM3_tai5
    
RUN cat $LM_tai5 | gzip > $LM_tai5_GZ
RUN utils/format_lm.sh tshi3/lang_dict $LM_tai5_GZ tshi3/local/dict/lexicon.txt tshi3/lang-1gram

RUN cat $LM3_tai5 | gzip > $LM3_tai5_GZ
RUN utils/build_const_arpa_lm.sh $LM3_tai5_GZ tshi3/lang-1gram tshi3/lang-3grams


RUN git pull
RUN bash -c 'rm -rf exp/{tri1,tri2,tri3,tri4}/decode_train_dev*'
RUN bash -c 'time bash -x 走評估.sh data/lang-1gram tshi3/train'

RUN bash -c 'time bash 看結果.sh'
