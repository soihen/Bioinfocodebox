import requests
import os
import sys
import json


def get_samples(dir):
    return [i for i in os.listdir(dir) if i.endswith("bam")]


def connect_cms():
    userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36"
    header = {"User-Agent": userAgent}
    postUrl = "http://cms.topgen.com.cn/user/login/auth"
    postData = {"userName": "bioinfo", "password": "top50800383"}
    response = requests.post(postUrl, params=postData, headers=header)
    token = json.loads(response.text)["data"]["accessToken"]
    return token

def get_sampleinfo(token, sampleID):
    userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36"
    header = {"User-Agent": userAgent}
    url = "http://cms.topgen.com.cn/sample/sample/search?report=true"

    param = {"accessToken": token, "search[sampleSn]": sampleID}
    response = requests.get(url, params=param, headers=header)
    data = json.loads(response.text)['data']
    if data:
        return data[0]['source']
    else:
        return 'test'

if __name__ == "__main__":
    samples = get_samples(sys.argv[1])

    token = connect_cms()
    for samplefile in samples:
        sampleID = samplefile.split('.')[0].rstrip('CF')
        print(sampleID,get_sampleinfo(token, sampleID))
        # print(os.path.basename(os.path.realpath(sys.argv[1])), sampleID, "\t".join(get_sampleinfo(token, sampleID)), sep="\t")
