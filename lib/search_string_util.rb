#! ruby -Ku
# encoding: utf-8

class SearchStringUtil
    class << self
        def create_search_string(text)
            search_string = text.gsub(/[-='&%$!"#:;@_]/,"")
            search_string.gsub!(/[、。！？ー〜～＄％＆”’（）｛｝「」＾＝；：＜＞＿]/,"")
            search_string.gsub!(/[\~\^\*\+\.\‘\[\]\/\{\}\(\)\<\>]/,"")

            search_string
        end
    end
end
