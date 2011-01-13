class String
  def extract!(pattern, group = 0)
    extracted = nil
    gsub!(pattern) do |match|
      extracted = $~[group]
      ""
    end
    extracted
  end
end
