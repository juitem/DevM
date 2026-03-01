import { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [status, setStatus] = useState(null);
  const [input, setInput] = useState('');
  const [result, setResult] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    fetchStatus();
  }, []);

  const fetchStatus = async () => {
    try {
      const response = await fetch('http://localhost:8000/api/status');
      const data = await response.json();
      setStatus(data);
    } catch (error) {
      console.error('Error:', error);
    }
  };

  const handleProcess = async () => {
    setLoading(true);
    try {
      const response = await fetch('http://localhost:8000/api/process', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ data: input })
      });
      const data = await response.json();
      setResult(data.result);
    } catch (error) {
      console.error('Error:', error);
      setResult('처리 실패');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="App">
      <header>
        <h1>🚀 Python + React GUI</h1>
        <p>Ubuntu 24.04 + Python 3.12 + React (Single Container)</p>
      </header>

      <main>
        {status && (
          <div className="status-box">
            <h2>📊 시스템 정보</h2>
            <div className="info-grid">
              <div className="info-item">
                <span className="label">상태:</span>
                <span className="value">{status.status}</span>
              </div>
              <div className="info-item">
                <span className="label">Python:</span>
                <span className="value">{status.python_version}</span>
              </div>
              <div className="info-item">
                <span className="label">Platform:</span>
                <span className="value">{status.platform}</span>
              </div>
            </div>
          </div>
        )}

        <div className="input-box">
          <h2>⚙️ 데이터 처리</h2>
          <input
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            placeholder="처리할 데이터를 입력하세요"
            onKeyPress={(e) => e.key === 'Enter' && handleProcess()}
          />
          <button onClick={handleProcess} disabled={loading}>
            {loading ? '처리 중...' : '▶ 처리'}
          </button>
        </div>

        {result && (
          <div className="result-box">
            <h3>✅ 결과:</h3>
            <p>{result}</p>
          </div>
        )}
      </main>
    </div>
  );
}

export default App;
