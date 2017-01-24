module ApplicationHelper

  def convert_ms_to_time(millisec)
    sec = (millisec/1000).to_s
    return Date.strptime(sec, '%s')
  end

  def convert_ms_to_short_time(millisec)
    sec = (millisec/1000).to_s
    date = Date.strptime(sec, '%s')
    return "#{date.day} - #{Date::MONTHNAMES[date.mon][0..2]}"
  end

  

end
