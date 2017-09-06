module TimeFormatable
  extend ActiveSupport::Concern
  VALIDTYPE = {
    big_endian: [0, 1, 2],
    little_endian: [2, 1, 0],
    middle_endian: [2, 0, 1]
  }

  DIGIT_NUMBER = {
    '零' => 0,
    '一' => 1,
    '二' => 2,
    '三' => 3,
    '四' => 4,
    '五' => 5,
    '六' => 6,
    '七' => 7,
    '八' => 8,
    '九' => 9
  }

  module ClassMethods
    def need_format_time *columns
      columns.each do |column|
        define_method "#{column}=" do |time|
          number_array = time.scan(/\d+/)
          number_array = parse_chinese_date(time) if number_array.length != 3
          year, month, day = get_date(number_array)
          write_attribute(column, Date.new(year, month, day))
        end
      end
    end
  end

  private

  # 按照不同的格式来取出年月日
  def get_date number_array
    type = ENV['time_format']&.to_sym
    type = VALIDTYPE.keys.include?(type) ? type : :big_endian
    times = VALIDTYPE[type].map do |index|
      number_array[index].to_i
    end
    return valid_check(*times)
  end

  # 是否在合法范围内
  def valid_check year, month, day
    year = year + 2000 if year.between?(0, 99)
    raise TimeparseException unless year.between?(0, 9999) && month.between?(1, 12) && day.between?(1, 31)
    return year, month, day
  end

  # 取出中文的年月日
  def parse_chinese_date time
    number_array = time.split(/[年,月,号]/)
    raise TimeparseException if number_array.length != 3
    get_date_from_chinese number_array
  end

  # 中文日期改为返回阿拉伯数字日期
  def get_date_from_chinese number_array
    number_array.map do |chinese_number|
      parse_chinese_number chinese_number
    end
  end

  # 解析中文数字，百以下
  def parse_chinese_number number_str
    if number_str.include?('十')
      left, right = number_str.match(/(.*)十(.*)/)[1..2]
      left = replace_number(left.blank? ? '一' : left)
      right = replace_number(right)
      left * 10 + right
    else
      replace_number(number_str)
    end
  end

  # 将中文直接转换为阿拉伯数字
  def replace_number number_str
    number_str.gsub(/\S/){ |w| DIGIT_NUMBER[w] }.to_i
  end
end
class TimeparseException < StandardError; end
