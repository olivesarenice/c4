# PSYCHE NETWORK - STYLE GUIDE

**Agent Instruction:** Use this guide when generating React pages for the data app. It defines the Psyche Network retro-terminal design language: CSS variables, reusable components, chart config, page layout, and modification constraints.

---

## 1. DESIGN PHILOSOPHY

* **Theme:** Retro-terminal, data-heavy, phosphor display.
* **Vibe:** Scientific, raw, cooperative network.
* **Density:** High. Little whitespace. Compact data presentation.

---

## 2. GLOBAL CSS (ShadCN variables)

Add this to your `globals.css` or `index.css`. It overwrites standard ShadCN variables.

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 135 15% 12%; /* Very dark green */
    --foreground: 135 60% 55%; /* Phosphor green */
    
    --card: 135 15% 12%;
    --card-foreground: 135 60% 55%;
    
    --popover: 135 15% 12%;
    --popover-foreground: 135 60% 55%;
    
    --primary: 135 60% 55%;
    --primary-foreground: 135 15% 12%;
    
    --secondary: 135 20% 20%;
    --secondary-foreground: 135 60% 55%;
    
    --muted: 135 20% 20%;
    --muted-foreground: 135 40% 45%;
    
    --accent: 50 90% 70%; /* Pale yellow for actions */
    --accent-foreground: 135 15% 12%;
    
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 210 40% 98%;

    --border: 135 40% 30%; /* Thin green lines */
    --input: 135 40% 30%;
    --ring: 135 60% 55%;

    --radius: 0rem; /* NO rounded corners */
  }
}

@layer base {
  * {
    @apply border-border;
  }
  body {
    @apply bg-background text-foreground uppercase antialiased;
  }
  h1, h2, h3, h4, h5, h6 {
    font-family: 'Times New Roman', Times, serif; /* Classic serif for headings */
    text-transform: lowercase; /* Psyche style */
    letter-spacing: 0.05em;
  }
  p, span, div, table, button {
    font-family: 'Courier New', Courier, monospace; /* Monospace for everything else */
    text-transform: uppercase;
  }
}
```

---

## 3. COMPONENT SNIPPETS

### 3.1. Framed Card (For Layouts)

```jsx
export function TerminalCard({ title, children }) {
  return (
    <div className="border border-border p-4 bg-background">
      <div className="mb-4 text-sm font-mono tracking-widest text-foreground/80 flex justify-between">
        <span>[{title}]</span>
        {/* Optional metric slot here */}
      </div>
      <div className="w-full">
        {children}
      </div>
    </div>
  );
}
```

### 3.2. Data Table (Mining Pool style)

```jsx
export function DataTable({ data }) {
  return (
    <div className="w-full overflow-x-auto text-xs font-mono">
      <table className="w-full text-left border-collapse">
        <thead>
          <tr className="border-b border-border/50 text-muted-foreground">
            <th className="py-2 pr-4 font-normal">RANK</th>
            <th className="py-2 pr-4 font-normal">ADDRESS</th>
            <th className="py-2 font-normal text-right">CONTRIBUTION</th>
          </tr>
        </thead>
        <tbody>
          {data.map((row, i) => (
            <tr key={i} className="border-b border-border/30 hover:bg-muted/30">
              <td className="py-2 pr-4">{row.rank}</td>
              <td className="py-2 pr-4 truncate max-w-[200px]">{row.address}</td>
              <td className="py-2 text-right">{row.contribution}%</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
```

### 3.3. Action Button

```jsx
export function ActionButton({ children, onClick }) {
  return (
    <button 
      onClick={onClick}
      className="bg-accent text-accent-foreground px-4 py-1 font-mono text-sm uppercase hover:bg-accent/80 transition-colors"
    >
      {children}
    </button>
  );
}
```

---

## 4. CHART CONFIGURATION (Recharts)

For the jagged, raw data charts.

```jsx
import { LineChart, Line, XAxis, YAxis, CartesianGrid, ResponsiveContainer } from 'recharts';

export function JaggedChart({ data }) {
  return (
    <ResponsiveContainer width="100%" height={200}>
      <LineChart data={data}>
        {/* Crosshair grid, thin lines */}
        <CartesianGrid strokeDasharray="3 3" stroke="var(--border)" horizontal={true} vertical={true} />
        
        <XAxis 
          dataKey="step" 
          stroke="var(--muted-foreground)" 
          fontSize={10} 
          tickLine={false} 
          axisLine={{ stroke: 'var(--border)' }}
        />
        <YAxis 
          stroke="var(--muted-foreground)" 
          fontSize={10} 
          tickLine={false} 
          axisLine={{ stroke: 'var(--border)' }}
          domain={['auto', 'auto']}
        />
        
        {/* No smoothing (type="linear"), no dots, raw jagged line */}
        <Line 
          type="linear" 
          dataKey="value" 
          stroke="var(--foreground)" 
          strokeWidth={1.5} 
          dot={false} 
          isAnimationActive={false} 
        />
      </LineChart>
    </ResponsiveContainer>
  );
}
```

---

## 5. LAYOUT RULES

1. **Global Background:** Must use the dark green background.
2. **Grid:** Use CSS Grid for complex layouts, keeping gaps tight (e.g., `gap-4`).
3. **Typography Rules:**
   * Headers (`h1`, `h2`): Lowercase, Serif.
   * Everything else: Uppercase, Monospace.
4. **Borders:** All containers, charts, and sections must have a 1px solid green border (`border-border`). No rounded corners.

---

## 6. PAGE SKELETON

```jsx
import { TerminalCard } from "@/components/TerminalCard";
import { DataTable } from "@/components/DataTable";
import { JaggedChart } from "@/components/JaggedChart";
import { ActionButton } from "@/components/ActionButton";

export default function DashboardPage() {
  // Agent: Fetch data here via async functions or React Query
  const poolData = [ ... ];
  const chartData = [ ... ];

  return (
    <div className="min-h-screen bg-background text-foreground p-6 font-mono uppercase">
      
      {/* HEADER SECTION */}
      <header className="flex justify-between items-center mb-8 border-b border-border pb-4">
        <div>
          <h1 className="font-serif text-3xl lowercase mb-1">dashboard</h1>
          <span className="text-xs tracking-widest text-muted-foreground">SYSTEM_STATUS: ONLINE</span>
        </div>
        <ActionButton>SYNC_DATA</ActionButton>
      </header>

      {/* MAIN GRID */}
      <main className="grid grid-cols-1 md:grid-cols-12 gap-6">
        
        {/* LEFT COLUMN: Data Table */}
        <div className="md:col-span-5">
          <TerminalCard title="INGESTION_QUEUE">
            <DataTable data={poolData} />
          </TerminalCard>
        </div>

        {/* RIGHT COLUMN: Charts */}
        <div className="md:col-span-7 flex flex-col gap-6">
          <TerminalCard title="METRIC: THROUGHPUT">
            <JaggedChart data={chartData} />
          </TerminalCard>
          
          <TerminalCard title="METRIC: LATENCY">
            <JaggedChart data={chartData} />
          </TerminalCard>
        </div>
        
      </main>
    </div>
  );
}
```

---

## 7. RULES FOR AGENT MODIFICATIONS

1. **Do not add padding or rounded corners** to make it look "modern". Keep it harsh and boxy.
2. **Do not use colors outside the defined variables.** Use `text-accent` for warnings or primary actions only.
3. **Data should look raw.** Do not smooth chart lines.
