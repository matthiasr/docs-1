require 'rails_helper'

RSpec.describe Page::Renderer do
  it "renders basic markdown" do
    md = <<~MD
      # Page title
      Some description
    MD

    html = <<~HTML
      <h1>Page title</h1>

      <p>Some description</p>
    HTML

    expect(Page::Renderer.render(md).strip).to eql(html.strip)
  end

  it "adds custom syntax highlighting for curl examples" do
    md = <<~MD
      ```bash
      curl "https://api.buildkite.com/v2/organizations/{org.slug}/builds"
      ```
    MD

    html = <<~HTML
      <div class="highlight"><pre class="highlight shell"><code>curl <span class="s2">"https://api.buildkite.com/v2/organizations/<span class="o">{org.slug}</span>/builds"</span>
      </code></pre></div>
    HTML

    expect(Page::Renderer.render(md).strip).to eql(html.strip)
  end

  it "supports {: code-filename=\"file.md\"} filenames for code blocks" do
    md = <<~MD
      ```json
      { "key": "value" }
      ```
      {: codeblock-file="file.json"}
    MD

    html = <<~HTML
      <figure class="highlight-figure"><figcaption>file.json</figcaption><div class="highlight"><pre class="highlight json"><code><span class="p">{</span><span class="w"> </span><span class="s2">"key"</span><span class="p">:</span><span class="w"> </span><span class="s2">"value"</span><span class="w"> </span><span class="p">}</span><span class="w">
      </span></code></pre></div></figure>
    HTML

    expect(Page::Renderer.render(md).strip).to eql(html.strip)
  end

  it 'supports custom Callouts' do
    md = <<~MD
      > 🚧 Troubleshooting: `launchctl` fails with "error"
      > Ensure **strong emphasis** works
      > Second paragraph has _emphasis_
    MD

    html = <<~HTML
      <section class="callout callout--troubleshooting">
        <p class="callout__title">
          <a class="callout__anchor" href="#troubleshooting-launchctl-fails-with-error" id="troubleshooting-launchctl-fails-with-error">🚧 Troubleshooting: <code>launchctl</code> fails with "error"</a>
        </p>
        <p>Ensure <strong>strong emphasis</strong> works</p>
      <p>Second paragraph has <em>emphasis</em></p>
      </section>
    HTML

    expect(Page::Renderer.render(md).strip).to eql(html.strip)
  end

  it 'supports custom Callouts without a title' do
    md = <<~MD
      > 🚧
      > Ensure **strong emphasis** works
      > Second paragraph has _emphasis_
    MD

    html = <<~HTML
      <section class="callout callout--troubleshooting">
        <p class="callout__title">
          🚧
        </p>
        <p>Ensure <strong>strong emphasis</strong> works</p>
      <p>Second paragraph has <em>emphasis</em></p>
      </section>
    HTML

    expect(Page::Renderer.render(md).strip).to eql(html.strip)
  end

  describe "Responsive table" do
    it "prepends faux th to each table cell" do
      md = <<~MD
        | Name   | Price    |
        | ------ | -------- |
        | Apple  | $4.00/kg |
        | Orange | $5.00/kg |
        {: class="responsive-table"}
      MD

      html_in_md = <<~HTML
        <table class="responsive-table">
        <thead>
        <tr>
        <th>Name</th>
        <th>Price</th>
        </tr>
        </thead>
        <tbody>
        <tr>
        <td>Apple</td>
        <td>$4.00/kg</td>
        </tr>
        <tr>
        <td>Orange</td>
        <td>$5.00/kg</td>
        </tr>
        </tbody>
        </table>
      HTML

      html = <<~HTML
        <table class="responsive-table">
        <thead>
        <tr>
        <th>Name</th>
        <th>Price</th>
        </tr>
        </thead>
        <tbody>
        <tr>
        <th aria-hidden class="responsive-table__faux-th">Name</th>
        <td>Apple</td>
        <th aria-hidden class="responsive-table__faux-th">Price</th>
        <td>$4.00/kg</td>
        </tr>
        <tr>
        <th aria-hidden class="responsive-table__faux-th">Name</th>
        <td>Orange</td>
        <th aria-hidden class="responsive-table__faux-th">Price</th>
        <td>$5.00/kg</td>
        </tr>
        </tbody>
        </table>
      HTML

      expect(Page::Renderer.render(md).strip).to eql(html.strip)
      expect(Page::Renderer.render(html_in_md).strip).to eql(html.strip)
    end

    it "does't affect tables without the .responsive-table CSS class" do
      md = <<~MD
        | Name   | Price    |
        | ------ | -------- |
        | Apple  | $4.00/kg |
        | Orange | $5.00/kg |
      MD

      html = <<~HTML
        <table>
        <thead>
        <tr>
        <th>Name</th>
        <th>Price</th>
        </tr>
        </thead>
        <tbody>
        <tr>
        <td>Apple</td>
        <td>$4.00/kg</td>
        </tr>
        <tr>
        <td>Orange</td>
        <td>$5.00/kg</td>
        </tr>
        </tbody>
        </table>
      HTML

      expect(Page::Renderer.render(md).strip).to eql(html.strip)
    end
  end
end
