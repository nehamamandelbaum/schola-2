# frozen_string_literal: true

class Subject < ApplicationRecord
  validates :name, presence: true,
                   uniqueness: true

  has_many :teacher_assignments, dependent: :destroy
  has_many :teachers, through: :teacher_assignments

  THEME = %w[
    Matemática
    Português
    História
    Geografia
    Física
    Química
    Inglês
  ].freeze
end
