class CreateVoiceGenerations < ActiveRecord::Migration[8.1]
  def change
    create_table :voice_generations do |t|
      t.text :text
      t.string :voice_id
      t.string :status, default: "pending"
      t.binary :audio_data
      t.string :voice_name
      t.string :user_text
      t.integer :duration
      t.integer :words_count
      t.text :error_message

      t.timestamps
    end
  end
end
