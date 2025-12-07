defmodule RealtimeQaWeb.HomeLive do
  use RealtimeQaWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <div class="container mx-auto px-4 py-16">
        <!-- Hero Section -->
        <div class="text-center mb-16">
          <h1 class="text-6xl font-bold text-gray-900 mb-4">
            FunAsk
          </h1>
          <p class="text-2xl text-gray-600 mb-8">
            Interactive Q&A platform for real-time engagement
          </p>
        </div>

        <!-- Action Cards -->
        <div class="max-w-5xl mx-auto grid md:grid-cols-2 gap-8">
          <!-- Join Room Card -->
          <div class="bg-white rounded-xl shadow-lg p-8 hover:shadow-2xl transition-shadow">
            <div class="text-center mb-6">
              <div class="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <svg class="w-8 h-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1"/>
                </svg>
              </div>
              <h2 class="text-3xl font-bold mb-2 text-gray-800">Join a Room</h2>
              <p class="text-gray-600">Enter a room code to participate</p>
            </div>

            <form phx-submit="join_room" class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">
                  Room Code
                </label>
                <input
                  type="text"
                  name="code"
                  class="w-full px-4 py-4 border-2 border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-center text-2xl font-mono uppercase tracking-widest"
                  placeholder="ABC123"
                  maxlength="6"
                  required
                />
              </div>
              <button
                type="submit"
                class="w-full bg-blue-600 text-white text-lg font-semibold px-6 py-4 rounded-lg hover:bg-blue-700 transition-all transform hover:scale-105"
              >
                Join Room →
              </button>
            </form>
          </div>

          <!-- Create Room Card -->
          <div class="bg-white rounded-xl shadow-lg p-8 hover:shadow-2xl transition-shadow">
            <div class="text-center mb-6">
              <div class="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <svg class="w-8 h-8 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/>
                </svg>
              </div>
              <h2 class="text-3xl font-bold mb-2 text-gray-800">Create a Room</h2>
              <p class="text-gray-600">Host your own Q&A session</p>
            </div>

            <%= if @current_user do %>
              <div class="space-y-4">
                <div class="flex items-center gap-3 p-4 bg-gradient-to-r from-green-50 to-blue-50 rounded-lg border border-green-200">
                  <div class="flex-1 min-w-0">
                    <p class="font-semibold text-gray-900 truncate">{@current_user.name}</p>
                    <p class="text-sm text-gray-600 truncate">{@current_user.email}</p>
                  </div>
                  <svg class="w-6 h-6 text-green-600" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/>
                  </svg>
                </div>
                <.link
                  navigate={~p"/dashboard"}
                  class="block w-full bg-green-600 text-white text-center text-lg font-semibold px-6 py-4 rounded-lg hover:bg-green-700 transition-all transform hover:scale-105"
                >
                  Go to Dashboard →
                </.link>
              </div>
            <% else %>
              <div class="space-y-4">
                <p class="text-gray-600 text-center mb-4">
                  Sign in with Google to create and manage rooms
                </p>

                <a
                  href={~p"/auth/google"}
                  class="flex items-center justify-center gap-3 w-full bg-white border-2 border-gray-300 text-gray-700 text-lg font-semibold px-6 py-4 rounded-lg hover:bg-gray-50 hover:border-gray-400 transition-all transform hover:scale-105 shadow-sm"
                >
                  <svg class="w-6 h-6" viewBox="0 0 24 24">
                    <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                    <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                    <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                    <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
                  </svg>
                  Sign in with Google
                </a>
                <p class="text-xs text-gray-500 text-center">
                  Free • No credit card required
                </p>
              </div>
            <% end %>
          </div>
        </div>

        <!-- Features Section -->
        <div class="max-w-5xl mx-auto mt-20">
          <h3 class="text-3xl font-bold text-center text-gray-900 mb-12">Why FunAsk?</h3>
          <div class="grid md:grid-cols-3 gap-8">
            <div class="text-center p-6">
              <div class="w-12 h-12 bg-purple-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <svg class="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/>
                </svg>
              </div>
              <h4 class="font-bold text-lg mb-2">Real-time Updates</h4>
              <p class="text-gray-600 text-sm">Questions and votes update instantly for all participants</p>
            </div>
            <div class="text-center p-6">
              <div class="w-12 h-12 bg-pink-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <svg class="w-6 h-6 text-pink-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
                </svg>
              </div>
              <h4 class="font-bold text-lg mb-2">Simple & Secure</h4>
              <p class="text-gray-600 text-sm">Easy to use with Google authentication</p>
            </div>
            <div class="text-center p-6">
              <div class="w-12 h-12 bg-yellow-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <svg class="w-6 h-6 text-yellow-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"/>
                </svg>
              </div>
              <h4 class="font-bold text-lg mb-2">Democratic Voting</h4>
              <p class="text-gray-600 text-sm">Popular questions rise to the top</p>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("join_room", %{"code" => code}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/room/#{String.upcase(code)}")}
  end
end
