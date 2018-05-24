---
layout: post_with_category2
title: Latest Posts
category: latest
categories: latest
badge: api
ctas:
  -
    title: Home
    link: /
  -
    title: Sign up for the Developer Sandbox
    link: https://sandbox.bluebutton.cms.gov/v1/accounts/create
---
{% for category in site.categories %}
{% capture category_name %}{{ category | first }}{% endcapture %}
{% if category_name == page.category %}
<div class="ds-l-col--12 ds-l-sm-col--7 {{ page.badge | slugify }}" id="main" role="main">
  {% for post in site.categories[category_name] %}
  <article class="archive-item">
    <h4><a href="{{ site.baseurl }}{{ post.url }}.html">{{post.title}}/</a></h4>
    {{ post.excerpt }}
  </article>
  {% endfor %}
</div>
{% endif %}
{% endfor %}

<!-- CBBP-1058 Fix 2 - export blog folder -->