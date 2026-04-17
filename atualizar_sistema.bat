@echo off
setlocal
title ECO FINANCEIRO - Deploy Automático

echo =======================================================
echo         ECO FINANCEIRO - SISTEMA DE GESTÃO
echo           INICIANDO BUILD E DEPLOY PARA O LINK
echo =======================================================
echo.

:: Passo 1: Limpeza e Instalação (opcional mas recomendado se houver erros)
:: echo [1/3] Verificando dependências...
:: call npm install

:: Passo 2: Build do projeto
echo [1/2] Criando versão otimizada (Build)...
call npm run build
if %errorlevel% neq 0 (
    echo.
    echo [ERRO] A criação do build falhou! Verifique o código.
    pause
    exit /b %errorlevel%
)

echo.
echo [2/2] Enviando para o Firebase (Hosting e Firestore)...
call npx firebase-tools deploy --only hosting,firestore
if %errorlevel% neq 0 (
    echo.
    echo [ERRO] Falha ao enviar para o Firebase!
    pause
    exit /b %errorlevel%
)

echo.
echo =======================================================
echo   CONCLUÍDO COM SUCESSO!
echo   O seu app já está atualizado no link:
echo   https://imperioecolog.web.app
echo =======================================================
echo.
pause
