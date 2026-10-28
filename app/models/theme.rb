class Theme
  FLAVOURS = %w[latte frappe macchiato mocha].freeze
  ACCENTS = %w[mauve pink flamingo lavender blue sky teal].freeze
  DEFAULT_ACCENT = "mauve"
  SYSTEM = "system"

  attr_reader :flavour, :accent

  def self.from(cookies)
    new(flavour: cookies[:flavour], accent: cookies[:accent])
  end

  def self.update(cookies, flavour: nil, accent: nil)
    if flavour == SYSTEM
      cookies.delete(:flavour)
    elsif FLAVOURS.include?(flavour)
      cookies.permanent[:flavour] = flavour
    end
    cookies.permanent[:accent] = accent if ACCENTS.include?(accent)
  end

  def initialize(flavour:, accent:)
    @flavour = flavour if FLAVOURS.include?(flavour)
    @accent = ACCENTS.include?(accent) ? accent : DEFAULT_ACCENT
  end

  def data = {flavour:, accent:}.compact
end
