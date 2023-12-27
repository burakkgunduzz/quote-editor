class Quote < ApplicationRecord
  belongs_to :company
  
  validates :name, presence: true

  scope :ordered, -> { order(id: :desc) }
  # below code is can be shortened with after_create_commit -> { broadcast_prepend_to "quotes" }
  after_create_commit -> { broadcast_prepend_to "quotes", partial: "quotes/quote", locals: { quote: self }, target:
    "quotes" }
  # To improve the performance we use broadcast_replace_later_to instead of broadcast_replace_to
  # in order to make broadcasting part asynchronous using background jobs.
  after_update_commit -> { broadcast_replace_later_to "quotes" }
  # The broadcast_remove_later_to method does not exist because as the quote gets deleted from
  # the database, it would be impossible for a background job to retrieve this quote in the
  # database later to perform the job.
  after_destroy_commit -> { broadcast_remove_to "quotes" }

  # Those three callbacks above are equivalent to the following single line
  # broadcasts_to ->(quote) { "quotes" }, inserts_by: :prepend
end
