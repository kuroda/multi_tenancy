module StringExtension
  refine String do
    def squash
      self.gsub(/\s+/, " ").strip
    end
  end
end
