import { Controller } from "@hotwired/stimulus"
import consumer from "../channels/consumer"

export default class extends Controller {
  static targets = ["form", "statusContainer", "statusMessage", "audioPlayer", "downloadLink"]
  
  connect() {
    this.pollInterval = null
  }
  
  generate(event) {
    event.preventDefault()
    
    const formData = new FormData(this.formTarget)
    this.showStatus("Generating voice...")
    
    fetch("/api/voice_generations", {
      method: "POST",
      body: formData
    })
    .then(response => response.json())
    .then(data => {
      this.currentGenerationId = data.id
      this.pollStatus(data.id)
    })
    .catch(error => {
      this.showStatus("Error generating voice. Please try again.")
      console.error("Generation error:", error)
    })
  }
  
  pollStatus(generationId) {
    this.pollInterval = setInterval(() => {
      fetch(`/api/voice_generations/${generationId}/status`)
        .then(response => response.json())
        .then(data => {
          this.updateStatus(data.status, data.audio_url, data.error)
          
          if (data.status === "completed" || data.status === "failed") {
            clearInterval(this.pollInterval)
          }
        })
    }, 1000)
  }
  
  updateStatus(status, audioUrl, error) {
    if (status === "completed" && audioUrl) {
      this.statusMessageTarget.textContent = "✅ Voice generated successfully!"
      this.audioPlayerTarget.src = audioUrl
      this.downloadLinkTarget.href = audioUrl
      this.audioPlayerTarget.classList.remove("hidden")
      this.downloadLinkTarget.classList.remove("hidden")
    } else if (status === "failed") {
      this.statusMessageTarget.textContent = `Generation failed: ${error}`
    } else {
      this.statusMessageTarget.textContent = `⏳ ${this.statusMessage(status)}`
    }
  }
  
  showStatus(message) {
    this.statusContainerTarget.classList.remove("hidden")
    this.statusMessageTarget.textContent = message
  }
  
  statusMessage(status) {
    const messages = {
      "pending": "Preparing voice generation...",
      "generating": "🎙️ Generating audio...",
      "completed": "✅ Ready!",
      "failed": "Failed"
    }
    return messages[status] || `Status: ${status}`
  }
  
  disconnect() {
    if (this.pollInterval) clearInterval(this.pollInterval)
  }
}
