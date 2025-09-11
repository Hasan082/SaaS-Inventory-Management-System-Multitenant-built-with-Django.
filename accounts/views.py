
from django.contrib.auth.views import LoginView
from django.views.generic.edit import FormView
from django.contrib.auth.models import User
from .forms import RegistrationForm, LoginForm
from django.urls import reverse_lazy
from django.shortcuts import redirect

class Login_View(LoginView):
    template_name = "login.html"
    form_class = LoginForm
    redirect_authenticated_user = True

class Register_View(FormView):
    template_name = "register.html"
    form_class = RegistrationForm
    success_url = reverse_lazy("login")

    def form_valid(self, form):
        user = User.objects.create_user(
            username=form.cleaned_data["username"],
            email=form.cleaned_data["email"],
            password=form.cleaned_data["password1"],
            first_name=form.cleaned_data["first_name"],
            last_name=form.cleaned_data["last_name"]
        )
        return super().form_valid(form)