class Time
  def rfc_2822
    sprintf("%s, %02d %s %d %02d:%02d:%02d ", RFC_2822_DAYS[wday], day,
            RFC_2822_MONTHS[mon-1], year, hour, min, sec) +
    if utc?
      "-0000"
    else
      sign = utc_offset <= 0 ? "-" : "+"
      offset = (utc_offset.abs / 60).divmod(60)
      sprintf "%s%02d%02d", sign, *offset
    end
  end
  
  RFC_2822_DAYS = %w(Sun Mon Tue Wed Thu Fri Sat)
  RFC_2822_MONTHS = %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
end
