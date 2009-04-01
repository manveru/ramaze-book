module Ramaze
  module Helper
    module Locale
      LOOKUP << self

      def locale(name)
        session[:LOCALE] = name
      end
    end
  end
end
