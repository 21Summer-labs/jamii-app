import React, { useState } from 'react';
import { Search, Mic, Camera } from 'lucide-react';
import { toast } from "sonner";

const mockSuggestions = [
];

const SearchBar = () => {
  const [query, setQuery] = useState('');
  const [showSuggestions, setShowSuggestions] = useState(false);
  const [isListening, setIsListening] = useState(false);

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault();
    console.log('Searching for:', query);
  };

  const handleVoiceSearch = async () => {
    try {
      if (!('webkitSpeechRecognition' in window)) {
        toast.error("Voice search is not supported in your browser");
        return;
      }

      const SpeechRecognition = (window as any).webkitSpeechRecognition;
      const recognition = new SpeechRecognition();
      
      recognition.onstart = () => {
        setIsListening(true);
        toast.info("Listening...");
      };

      recognition.onresult = (event: any) => {
        const transcript = event.results[0][0].transcript;
        setQuery(transcript);
        setIsListening(false);
      };

      recognition.onerror = () => {
        setIsListening(false);
        toast.error("Error occurred in voice recognition");
      };

      recognition.onend = () => {
        setIsListening(false);
      };

      recognition.start();
    } catch (error) {
      toast.error("Error starting voice recognition");
      setIsListening(false);
    }
  };

  const handleImageSearch = () => {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = 'image/*';
    input.onchange = (e) => {
      const file = (e.target as HTMLInputElement).files?.[0];
      if (file) {
        // Check file size (max 5MB)
        if (file.size > 5 * 1024 * 1024) {
          toast.error("File size should be less than 5MB");
          return;
        }

        // Check file type
        if (!file.type.startsWith('image/')) {
          toast.error("Please upload an image file");
          return;
        }

        const reader = new FileReader();
        reader.onload = () => {
          toast.success("Image uploaded successfully");
          // Here you would typically send the image to your backend
          // For now, we'll just show a success message
          console.log('Image file:', file.name);
        };
        reader.onerror = () => {
          toast.error("Error reading file");
        };
        reader.readAsDataURL(file);
      }
    };
    input.click();
  };

  return (
    <div className="relative w-full max-w-2xl mx-auto">
      <form onSubmit={handleSearch} className="relative">
        <div className="relative flex items-center">
          <input
            type="text"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            onFocus={() => setShowSuggestions(true)}
            placeholder="Search places..."
            className="w-full px-12 py-4 pr-24 bg-white/80 backdrop-blur-sm rounded-full border border-gray-200 shadow-lg focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all"
          />
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 w-5 h-5" />
          
          <div className="absolute right-4 top-1/2 -translate-y-1/2 flex items-center gap-2">
            <button
              type="button"
              onClick={handleVoiceSearch}
              className={`p-2 rounded-full hover:bg-gray-100 transition-colors ${isListening ? 'text-blue-500' : 'text-gray-400'}`}
              title="Search by voice"
            >
              <Mic className="w-5 h-5" />
            </button>
            <button
              type="button"
              onClick={handleImageSearch}
              className="p-2 rounded-full hover:bg-gray-100 transition-colors text-gray-400"
              title="Search by image"
            >
              <Camera className="w-5 h-5" />
            </button>
          </div>
        </div>
      </form>

      {showSuggestions && query && (
        <div className="absolute w-full mt-2 bg-white/80 backdrop-blur-sm rounded-2xl shadow-lg border border-gray-200 overflow-hidden animate-fade-in">
          {mockSuggestions
            .filter(suggestion => 
              suggestion.toLowerCase().includes(query.toLowerCase())
            )
            .map((suggestion, index) => (
              <button
                key={index}
                onClick={() => {
                  setQuery(suggestion);
                  setShowSuggestions(false);
                }}
                className="w-full px-6 py-3 text-left hover:bg-white/60 transition-colors"
              >
                {suggestion}
              </button>
            ))}
        </div>
      )}
    </div>
  );
};

export default SearchBar;