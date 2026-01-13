import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "form", "statusContainer", "statusMessage", "audioPlayer", "downloadLink" ]
  
  connect() {
    console.log("🎙️ VoiceGenerator connected")
  }
  
  generate(event) {
    event.preventDefault()
    
    // Client-side validation
    const text = this.formTarget.querySelector("[name*='text']").value.trim()
    if (!text) {
      this.showStatus("⚠️ Please enter some text first!", "error")
      return
    }
    
    this.showStatus("🚀 Creating voice generation request...")
    this.disableForm()
    
    const formData = new FormData(this.formTarget)
    
    fetch(this.formTarget.action, {
      method: "POST",
      body: formData,
      headers: { "X-Requested-With": "XMLHttpRequest" }
    })
    .then(response => response.json())
    .then(data => {
      if (data.id) {
        this.currentId = data.id
        this.pollStatus(data.id)
      } else {
        this.showStatus("❌ Failed to create generation", "error")
      }
    })
    .catch(error => {
      this.showStatus("❌ Network error. Please try again.", "error")
      this.enableForm()
    })
  }
  
  pollStatus(id) {
    this.pollInterval = setInterval(() => {
      fetch(`/api/voice_generations/${id}/status`)
        .then(r => r.json())
        .then(data => this.updateStatus(data))
    }, 1500)
  }
  
  updateStatus(data) {
    const messages = {
      pending: "📝 Preparing voice generation...",
      generating: "🎙️ Generating high-quality audio with AI...",
      completed: "✅ Voice ready! 🎉",
      failed: `❌ Failed: ${data.error}`
    }
    
    this.statusMessageTarget.textContent = messages[data.status] || "⏳ Processing..."
    this.statusMessageTarget.className = `text-2xl font-bold text-center mb-8 ${data.status}`
    
    if (data.status === "completed" && data.audio_url) {
      this.audioPlayerTarget.src = data.audio_url
      this.downloadLinkTarget.href = data.audio_url
      this.audioPlayerContainerTarget.classList.remove("hidden")
      clearInterval(this.pollInterval)
    } else if (data.status === "failed") {
      clearInterval(this.pollInterval)
      this.enableForm()
    }
  }
  
  showStatus(message, type = "info") {
    this.statusContainerTarget.classList.remove("hidden")
    this.statusMessageTarget.textContent = message
  }
  
  disableForm() {
    this.formTarget.querySelector("button[type=submit]").disabled = true
  }
  
  enableForm() {
    this.formTarget.querySelector("button[type=submit]").disabled = false
  }
}
