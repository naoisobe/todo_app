import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    // focus the input when the controller is present
    if (this.hasInputTarget) this.inputTarget.focus()
  }

  edit(event) {
    const todoId = event.target.dataset.todoId
    if (todoId) {
      // Turbo requestで編集フォームを表示
      const form = document.createElement('form')
      form.method = 'GET'
      form.action = `/todos/${todoId}/edit`
      form.setAttribute('data-turbo', 'true')
      
      document.body.appendChild(form)
      form.submit()
      document.body.removeChild(form)
    }
  }

  handleEscape(event) {
    if (event.key === 'Escape') {
      // Escapeキーで編集をキャンセル
      const todoId = this.element.closest('[id^="todo_"]').id.replace('todo_', '')
      const form = document.createElement('form')
      form.method = 'GET'
      form.action = `/todos/${todoId}/edit?cancel=true`
      form.setAttribute('data-turbo', 'true')
      
      document.body.appendChild(form)
      form.submit()
      document.body.removeChild(form)
    }
  }
}
