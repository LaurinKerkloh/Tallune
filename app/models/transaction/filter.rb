class Transaction::Filter
  include ActiveModel::Model
  include ActiveModel::Attributes

  DIRECTIONS = %w[income spending].freeze
  SEARCH_PARAMS = %i[q from to direction].freeze

  attribute :account_ids, default: -> { [] }
  attribute :import_ids, default: -> { [] }
  attribute :q, :string
  attribute :from, :date
  attribute :to, :date
  attribute :direction, :string

  def self.from(params, **ids)
    new(params.permit(*SEARCH_PARAMS, account_ids: [], import_ids: []).merge(ids))
  end

  def account_ids=(ids)
    super(cast_ids(ids))
  end

  def import_ids=(ids)
    super(cast_ids(ids))
  end

  def apply(scope)
    scope = scope.where(account_id: account_ids) if account_ids.any?
    scope = scope.where(import_id: import_ids) if import_ids.any?
    scope = search(scope) if q.present?
    scope = scope.where(booked_on: from..) if from
    scope = scope.where(booked_on: ..to) if to
    scope = scope.public_send(direction) if DIRECTIONS.include?(direction)
    scope.order(booked_on: :desc, id: :desc)
  end

  # The ids only say which transactions to look at, so they don't count as filters to clear.
  def any?
    search_params.any?
  end

  def to_params
    id_params.merge(search_params)
  end

  def id_params
    {account_ids: account_ids.presence, import_ids: import_ids.presence}.compact
  end

  def search_params
    {q: q.presence, from:, to:, direction: (direction if DIRECTIONS.include?(direction))}.compact
  end

  private

  def cast_ids(ids)
    Array(ids).compact_blank.map(&:to_i)
  end

  def search(scope)
    pattern = "%#{Transaction.sanitize_sql_like(q)}%"
    # SQLite has no default escape character, so the backslashes from sanitize_sql_like need ESCAPE.
    scope.left_joins(:counterparty).where(
      "counterparties.name LIKE :pattern ESCAPE '\\' OR transactions.reference LIKE :pattern ESCAPE '\\'", pattern:
    )
  end
end
