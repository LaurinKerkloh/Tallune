module HasIban
  extend ActiveSupport::Concern

  IBAN_FORMAT = /\A[A-Z]{2}\d{2}[A-Z0-9]{11,30}\z/

  included do
    # Blank becomes nil so the partial unique indexes on iban IS NULL apply. [[:space:]] also covers the
    # non-breaking spaces that come with IBANs copied from banking web pages.
    normalizes :iban, with: ->(iban) { iban.gsub(/[[:space:]]/, "").upcase.presence }

    validate :iban_must_be_valid
  end

  def formatted_iban = iban&.scan(/.{1,4}/)&.join(" ")

  private

  def iban_must_be_valid
    return if iban.nil?

    errors.add(:iban, :invalid) unless IBAN_FORMAT.match?(iban) && iban_checksum_valid?
  end

  # ISO 13616: move the country code and check digits to the end, turn letters into 10..35, and the result mod 97 is 1.
  def iban_checksum_valid?
    (iban[4..] + iban[0, 4]).gsub(/[A-Z]/) { (it.ord - 55).to_s }.to_i % 97 == 1
  end
end
