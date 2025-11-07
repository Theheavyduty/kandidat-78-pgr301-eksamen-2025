Innledning
KI-assistert utvikling kan øke tempoet dramatisk, men det endrer også risikoprofilen og krever strammere DevOps-praksis. I denne drøftingen vurderer jeg hvordan KI påvirker de tre DevOps-prinsippene – flyt, feedback og kontinuerlig læring – med eksempler fra oppgavene: Terraform for S3 og CloudWatch, GitHub Actions for SAM/Docker, samt instrumentering/alarmer med Micrometer og CloudWatch.
1. Flyt (Flow)
Muligheter. KI reduserer tiden fra idé til kjørende løsning ved å generere “boilerplate” raskt: Terraform-moduler, GitHub Actions-workflow, Dockerfile, og Spring-kode for Micrometer. I praksis brukte jeg KI til å:


omskrive SAM-workflow slik at PR kun kjører validate/build mens deploy skjer på main (bedre release-hygiene),


lage multi-stage Dockerfile (Maven build + Corretto runtime),


skissere Terraform for dashboard, alarm og SNS, med variabler og fornuftige defaults,


foreslå Micrometer-målinger (Timer, Gauge, DistributionSummary) og CloudWatch-dashbord/metric-math.


Dette fjerner flaskehalser i repetitivt arbeid (YAML/JSON/TF-stubber) og reduserer “context switching” mellom dokumentasjon og kode.
Nye flaskehalser. KI kan introdusere feil som er kjappe å skrive, men trege å avdekke: jeg fikk f.eks. en DistributionSummary-feil (minimumExpectedValue må være > 0) og snafu i CloudWatch alarm-API fordi ReturnData ikke var satt på råserier. Slike detaljer er lette å overse i generert kode. En annen flaskehals er miljøantakelser: Docker-kjøring feilet først på manglende AWS-credentials og senere på feil bucket; KI kan ikke “se” ditt miljø. Summen er at verifikasjon blir den nye tiden du må investere.
Code review og deploy. AI-generert kode krever tydeligere review-kriterier: konvensjoner, sikkerhet (Secrets i Actions, ikke hardkoding), regioner og navnerom. Jeg brukte path-filtrering i Actions (kjør kun på relevante mapper) og “plan før apply” i Terraform for å redusere risiko. KI hjelper flyten mest når outputen går rett inn i en pipeline som avslører avvik raskt.
2. Feedback
Tilpassede feedback-sløyfer. Når deler av koden er KI-generert, bør feedback være tettere og mer automatisert. I praksis:


CI for infrastruktur: terraform fmt/validate/plan på PR, apply på main. Dermed fanges syntaks/plan-feil før deploy.


Runtime-telemetri: Micrometer-instrumentering (Timer for Bedrock-kall, Gauge for antall selskaper, DistributionSummary for confidence). Dashboard i CloudWatch med metric-math (sum/count) ga umiddelbar innsikt i latency og kvalitet.


Alarmer: Jeg definerte alarm på gjennomsnittlig latency og verificerte den både ved manuell test og via reell trafikk. treat_missing_data = notBreaching forklarer hvorfor alarmen gikk tilbake til OK uten datapunkter – en viktig del av feedback-design.


Oppdage problemer tidlig. Vi fanget miljøfeil (manglende AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY) og feil bucket gjennom 500-feil i APIet, og svarene ble koblet til observabilitet: null-datapunkter i CloudWatch førte til CLI-spørringer og justering av perioder/statistikk. Poenget er at når KI skriver koden, må test, observability og alarmer være kompensasjonen som sikrer tidlig og målbar feedback.
Lærer verktøyene over tid? Ikke i seg selv, men teamet kan “lære inn” guardrails: maler for workflows, modulære TF-filer, navnestandarder (eget namespace per kandidat), og “golden queries” i CLI. Dermed blir feedback raskere og mer pålitelig for neste iterasjon.
3. Kontinuerlig læring og forbedring
Læringspåvirkning. KI fungerer som en “junior kollega” som foreslår løsninger og forklarer API-er. Det øker breddelæring (du kommer raskere i gang med ukjent teknologi), men kan hemme dybdelæring hvis man aksepterer output ukritisk. I oppgaven ga feilene svært konkret læring: hvorfor DistributionSummary ikke kan ha min=0, hvordan ReturnData=false er nødvendig i CloudWatch alarm-spørringer, og betydningen av treat_missing_data.
Risiko for kompetansetap. Overdreven bruk kan føre til at utviklere glemmer grunnleggende prinsipper (IAM, nettverk, tilstandsforståelse i Terraform). Mottiltak:


krev manuelle reviews med fokus på sikkerhet og kost,


eierskap til runbooks og “why”-kommentarer i koden,


retrospektiver hvor teamet dokumenterer hva KI foreslo og hva vi endret.


Kunnskapsdeling. IaC i repoet, README_SVAR.md med terskelbegrunnelser, og dashboards/alarmer som “levende dokumentasjon” sikrer at læring blir kollektiv. Nye ferdigheter som trengs: skrive verifiserbare prompts/akseptansekriterier, tolke CI/observability-signal, og praktisk sikkerhet (secrets-håndtering, minst privilegium).
Konklusjon
KI kan gi betydelig bedre flyt ved å automatisere stillas og repetisjon, men kun når output raskt valideres i CI og i produksjon. Feedback må styrkes: tester, telemetri, dashboards og alarmer gjør at vi oppdager AI-feil tidlig og kobler dem til målbare signaler. Kontinuerlig læring skjer når vi bruker KI som sparringspartner, men beholder menneskelig dømmekraft og bygger teamets “guardrails” i kode, dokumentasjon og prosess. Den beste balansen jeg erfarte i oppgaven er: la KI skrive førsteutkastet, la pipeline og observabilitet dømme, og la teamet justere – slik blir både tempo, kvalitet og læring bedre over tid.

### Oppgave 2 
- Her er url: https://79ba8jc1jh.execute-api.eu-west-1.amazonaws.com/Prod/analyze/ 
- Her er s43 object: s3://kandidat-78-data/midlertidig/comprehend-20251107-225637-2718ec4f.json